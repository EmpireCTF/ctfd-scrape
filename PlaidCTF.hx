import haxe.Json;

class PlaidCTF {
  public static function run(api:String, cookie:String):CTF {
    function req(endpoint:String):Dynamic {
      var url = '$api/$endpoint';
      var cacheId = "cache/" + endpoint.split("/").join("-") + ".json";
      var parsed:haxe.DynamicAccess<Dynamic> = Json.parse(url.requestString(cacheId));
      if (!parsed.exists("code") || (parsed.get("code"):Int) != 100 || !parsed.exists("msg"))
        throw 'cannot retrieve ${url} (not PlaidCTF?)';
      return parsed.get("msg");
    }
    var rawList:Array<PlaidCTFChallenge> = req("problems/list").problems;
    // TODO: follow redirect on teams/info
    var solved:Array<Int> = (req("teams/profile/89"):{solved_problems:Array<{id:Int}>}).solved_problems.map(c -> c.id);
    var linkRE = ~/<a href="\/files\/([^"]+)" target="_blank">([^<]+)<\/a>/; // "
    return {
        challenges: rawList.map(c -> {
            var files = [];
            {
               category: c.category
              ,name: c.name
              ,description: linkRE.map(c.description, l -> {
                  files.push(l.matched(1));
                  '[${l.matched(2)}](files/${l.matched(1)})';
                })
              ,files: files
              ,value: (c.keys[0].value:Int)
              ,solved: solved.indexOf(c.id) != -1
            };
          })
      };
  }
}

typedef PlaidCTFData = {
    challenges:Array<PlaidCTFChallenge>
  };

typedef PlaidCTFChallenge = {
     id:Int
    ,category:String
    ,name:String
    ,description:String
    ,keys:Array<Dynamic>
  };
