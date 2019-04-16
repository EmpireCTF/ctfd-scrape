typedef CTF = {
    challenges:Array<CTFChallenge>
  };

typedef CTFChallenge = {
     category:String
    ,name:String
    ,description:String
    ,files:Array<String>
    ,value:Int
    ,?solved:Bool
  };
