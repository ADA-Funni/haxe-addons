# haxe-addons
Adds new features to Haxe, like @:async functions and @:await vars.

## A Guide to haxe-addons's Async
If there's no @:await vars, the function just gets run on a separate thread and the thread gets killed as normal.

If there are @:await vars, the compiler waits for you to set status to 1 before letting the main thread continue. That method basically tells the macro that it's A-OK to stop blocking the main thread because all your variables have been set for that function. 

Here's some code to get you started:
```haxe
package;

class Main implements haxe.addons.async.Async {
  static function main() {
    var promise = sendGJThing();
    trace("First await: " + promise);
    trace("Second await: " + recieveFromWeb());
  }

  @:async static function sendGJThing():Void {
    // If there's no @:await vars, the function just gets run on a separate thread.
    final helloWorld = sys.io.File.getContent("fetch.txt");
    trace(helloWorld);
  }

  @:async static function recieveFromWeb():String {
    // If there are @:await vars, the compiler... waits... for you to set `status` to `1`.
    @:await var result:String = null;

    var http = new haxe.Http('https://google.com');
    http.onData = d -> {
      result = d;
      status = 1;
    };
    http.request(false);

    return result;
  }
}
```