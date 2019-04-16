import sys.io.File;
import sys.FileSystem;
import sys.Http;

class HTTPUtils {
  public static var cookie:String;
  
  public static function requestString(url:String, ?cacheId:String):String {
    Sys.print('GET $url ... ');
    if (cacheId != null && FileSystem.exists(cacheId)) {
      Sys.println("cached");
      return File.getContent(cacheId);
    }
    var http = new Http(url);
    var res:String = null;
    if (cookie != null) http.addHeader("Cookie", cookie);
    http.onData = function (r) res = r;
    http.onError = function (e) throw 'http error $e';
    http.request();
    if (cacheId != null) File.saveContent(cacheId, res);
    Sys.println("ok");
    return res;
  }
}
