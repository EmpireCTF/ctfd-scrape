using StringTools;
using sys.FileSystem;

class Scrape {
  public static function main():Void {
    function usage(?err:Bool = true):Void {
      Sys.println("CTFd challenge scraper

Usage:
  neko scrape.n <API> <cookie> <output>

Options:
  <API>     full URL to CTFd API base (e.g. https://ctf.example.com/api/v1/)
  <cookie>  cookie used to authenticate to CTFd (e.g ctfd=xyz;session=xyz)
  <output>  target file (e.g. README.md)
");
      Sys.exit(err ? 1 : 0);
    }
    
    function err(str:String):Void {
      Sys.println('error: $str
try \'neko scrape.n --help\' for usage');
      Sys.exit(1);
    }
    switch (Sys.args()) {
      case [api, cookie, output]:
      if (!api.startsWith("https://") && !api.startsWith("http://")) err("API must be a full HTTP or HTTPS URL");
      if (output.exists() && output.isDirectory()) err("output must not be an existing directory");
      if (output.exists()) {
        Sys.print("output file already exists, override? [y/N]: ");
        switch (Sys.stdin().readLine().toLowerCase()) {
          case "y" | "yes":
          case _: Sys.exit(0);
        }
      }
      var data = (try CTFd.run(api, cookie) catch (ex:String) { err('error during retrieval: $ex'); null; });
      Sys.println('${data.challenges.length} challenges found');
      sys.io.File.saveContent(output, Writeup.format(data));
      case ["--help"] | ["-?"] | ["-h"]: usage(false);
      case _: usage();
    }
  }
}
