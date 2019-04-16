using StringTools;

class Writeup {
  public static function format(data:CTF):String {
    var out = new StringBuf();
    formatHeader(out);
    var catMap = new Map<String, Array<CTF.CTFChallenge>>();
    for (c in data.challenges) {
      if (!catMap.exists(c.category)) catMap[c.category] = [];
      catMap[c.category].push(c);
    }
    var cats:CatMap = [ for (category => challenges in catMap) {category: category, challenges: challenges} ];
    cats.sort((a, b) -> Reflect.compare(a.category, b.category));
    formatToC(out, cats);
    formatChallenges(out, cats);
    return out.toString();
  }
  
  static function formatHeader(out:StringBuf):Void {
    out.add('# CTF-name #

[CTFTime link](https://ctftime.org/event/) | [Website]()

---

');
  }
  
  static var allowed = "abcdefghijklmnopqrstuvwxyz0123456789_".split("");
  static function slug(s:String):String return s.toLowerCase().split("").filter(c -> allowed.indexOf(c) != -1).join("");
  
  static function slugChallenge(chall:CTF.CTFChallenge):String return '${chall.value}-${slug(chall.category)}--${slug(chall.name)}';
  
  static function formatToC(out:StringBuf, cats:CatMap):Void {
    out.add('## Challenges ##
');
    for (c in cats) {
      out.add('
### ${c.category} ###

');
      for (chall in c.challenges) {
        out.add(' - [${chall.solved ? "x" : " "}] [${chall.value} ${chall.name}](#${slugChallenge(chall)})
');
      }
    }
    out.add('
---

');
  }
  
  static function formatChallenges(out:StringBuf, cats:CatMap):Void {
    var files = [];
    var fileDesc = [];
    for (c in cats) for (chall in c.challenges) {
      out.add('## ${chall.value} ${chall.category} / ${chall.name} ##

**Description**

');
      for (line in chall.description.split("\n")) out.add('> ${line.trim()}
');
      if (chall.files != null && chall.files.length > 0) {
        out.add("
**Files provided**

");
        for (f in chall.files) {
          var dots = f.split("/").pop().split(".");
          var ext = "";
          if (dots.length > 1) {
            ext = "." + dots.pop();
          }
          var name = dots.join("");
          var file = '${slug(chall.name)}-${slug(name)}${ext}';
          if (files.indexOf(file) != -1) {
            var ctr = 1;
            while (files.indexOf('${slug(chall.name)}-${slug(name)}-${ctr}${ext}') != -1) ctr++;
            file = '${slug(chall.name)}-${slug(name)}-${ctr}${ext}';
          }
          files.push(file);
          fileDesc.push('${name} from ${chall.category} challenge ${chall.name}');
          out.add(' - [`${name}`](files/${file})
');
        }
      } else {
        out.add("
**No files provided**
");
      }
      if (chall.solved) {
        out.add("
**Solution**

(TODO)

");
      } else out.add("\n");
    }
    
    Sys.println("TODO - provide files:");
    for (i in 0...files.length) {
      Sys.println(' - ${files[i]} <- ${fileDesc[i]}');
    }
  }
}

typedef CatMap = Array<{category:String, challenges:Array<CTF.CTFChallenge>}>;
