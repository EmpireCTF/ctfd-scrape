import haxe.Json;

class CTFd {
  public static function run(api:String, cookie:String):CTF {
    function req(endpoint:String):Dynamic {
      var url = '$api/$endpoint';
      var cacheId = "cache/" + endpoint.split("/").join("-") + ".json";
      var parsed:haxe.DynamicAccess<Dynamic> = Json.parse(url.requestString(cacheId));
      if (!parsed.exists("success") || !(parsed.get("success"):Bool) || !parsed.exists("data"))
        throw 'cannot retrieve ${url} (not CTFd?)';
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

typedef CTFdCTF = {
    challenges:Array<CTFdChallenge>
  };

typedef CTFdChallenge = CTF.CTFChallenge & {
     id:Int
    ,state:String
    ,type:String
    ,max_attempts:Int
    ,tags:Array<{value:String}>
    ,hints:Array<{content:String, cost:Int, id:Int}>
    ,solves:Int
  };
