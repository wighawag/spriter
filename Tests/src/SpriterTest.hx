import haxe.macro.Expr;

@:access(spriter)
class SpriterTest{
	macro public static function createEntity(scml : String, entityName : String) : Expr{
		return macro Spriter.parseScml(Embed.fileContentAsString($v{scml})).createEntity($v{entityName});
	}
	
}