package haxe.addons.async;

import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

/**
 * Used to force anything that implements `haxe.addons.async.Async` to have `@:async` functions and `@:await` vars.
 */
class AsyncMacro {
  /**
   * Forces anything that implements `haxe.addons.async.Async` to have `@:async` functions and `@:await` vars.
   */
  public static macro function build():Array<Field> {
    var fields = Context.getBuildFields();

    function addAsyncRoutine(field:Field) {
      switch (field.kind) {
        case FFun(f):
          #if debug
          trace('@${field.meta.filter(e -> e.name == ':async')[0].name} function ${field.name}');
          #end

          var awaitVars:Int = 0;
          switch (f.expr.expr) {
            case EBlock(exprs):
              for (expr in exprs) {
                switch (expr.expr) {
                  case EMeta(s, e):
                    switch (e.expr) {
                      case EVars(vars):
                        for (v in vars) {
                          awaitVars++;
                          #if debug trace('@${s.name} ${v.isFinal ? 'final' : 'var'} ${v.name}'); #end
                        }
                      case _:
                    }
                  case _:
                }
              }
            case _:
          }

          if (awaitVars != 0) {
            var oldExpr = f.expr;
            f.expr = macro {
              // returnVal is Dynamic because there was an issue where
              // if you put the @:async function's return type as Void by mistake, it'd kill this macro.
              //
              // Now the compiler will only tell you you've fucked up through the value definitions in YOUR code.

              var status = 0;
              var returnVal:Dynamic = null;

              #if target.threaded
              sys.thread.Thread.create("HaxeAddonsAwaitThread", () -> {
                returnVal = cast (() -> $oldExpr)();
              });
              #else
              returnVal = cast (() -> $oldExpr)();
              #end

              while (status == 0)
                Sys.sleep(0.001);

              return cast returnVal;
            };
          } else {
            var oldExpr = f.expr;
            f.expr = macro {
              #if target.threaded
              sys.thread.Thread.create("HaxeAddonsAsyncThread", () -> {
                (() -> $oldExpr)();
              });
              #else
              (() -> $oldExpr)();
              #end
            };
          }
        case _:
      }
    }

    for (field in fields) {
      for (metadata in field.meta) {
        if (metadata.name == ':async')
          addAsyncRoutine(field);
      }
    }

    return fields;
  }
}