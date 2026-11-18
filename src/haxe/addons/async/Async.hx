package haxe.addons.async;

/**
 * Forces anything that implements this interface to have `@:async` functions and `@:await` vars.
 */
@:autoBuild(haxe.addons.async.AsyncMacro.build())
interface Async {}