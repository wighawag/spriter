import haxe.macro.Expr;


class Embed{
	macro public static function fileContentAsString(filePath : String): Expr{
		var content = sys.io.File.getContent(filePath);
		return macro $v{content};
	}
}