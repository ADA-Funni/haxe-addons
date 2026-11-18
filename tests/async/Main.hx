package;

class Main implements haxe.addons.async.Async {
  static function main() {
    sendGJThing();
    trace("start"); // This typically gets traced before `sendGJThing()` runs its trace, proving it is an asynchronous function.

    trace("Second await: " + recieveFromWeb());
    trace("end"); // This will always run after `recieveFromWeb()` is done, proving that it's blocking the main thread.

    Sys.exit(0); // Kill the app in case I screwed up.
  }

  @:async static function sendGJThing():Void {
    // If there's no @:await vars, the function just gets run on a separate thread.
    final helloWorld = sys.io.File.getContent("fetch.txt");
    trace("First await: " + helloWorld);
  }

  /**
   * This works perfectly.
   */
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
