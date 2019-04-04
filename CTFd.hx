import sys.io.File;
import sys.FileSystem;
import sys.Http;
import haxe.Json;

class CTFd {
  public static function run(api:String, cookie:String):CTFdData {
    if (api.substr(api.length - 1, 1) == "/") api = api.substr(0, api.length - 1);
    if (!FileSystem.exists("cache")) FileSystem.createDirectory("cache");
    function req(endpoint:String):Dynamic {
      var url = '$api/$endpoint';
      Sys.print('GET $url ... ');
      var res:String = null;
      var cacheId = "cache/" + endpoint.split("/").join("-") + ".json";
      if (FileSystem.exists(cacheId)) {
        res = File.getContent(cacheId);
        Sys.println("cached");
      } else {
        var http = new Http(url);
        http.addHeader("Cookie", cookie);
        //http.onData = function(r):Void res = r;
        http.onData = function (r) res = r;
        http.onError = function (e) throw 'http error $e';
        http.request();
        File.saveContent(cacheId, res);
        Sys.println("ok");
      }
      var parsed:haxe.DynamicAccess<Dynamic> = Json.parse(res);
      if (!parsed.exists("success") || !(parsed.get("success"):Bool)) throw 'cannot retrieve ${url}';
      return parsed.get("data");
    }
    var rawList:Array<{id:Int}> = req("challenges");
    var solved:Array<Int> = (req("teams/me/solves"):Array<{challenge_id:Int}>).map(c -> c.challenge_id);
    return {
        challenges: rawList.map(c -> {
            var chall:CTFdChallenge = req('challenges/${c.id}');
            chall.solved = solved.indexOf(chall.id) != -1;
            chall;
          })
      };
  }
}

typedef CTFdChallenge = {
     id:Int
    ,category:String
    ,name:String
    ,description:String
    ,files:Array<String>
    ,state:String
    ,type:String
    ,max_attempts:Int
    ,tags:Array<{value:String}>
    ,hints:Array<{content:String, cost:Int, id:Int}>
    ,solves:Int
    ,value:Int
    ,type_data:{templates:Dynamic, scripts:Dynamic, id:String, name:String}
    ,?solved:Bool
  };

typedef CTFdData = {
    challenges:Array<CTFdChallenge>
  };
