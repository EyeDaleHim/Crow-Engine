package crow.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import haxe.macro.Type.ClassType;

class FlxMacro
{
	public static macro function buildFlxBasic():Array<Field>
	{
		var pos:Position = Context.currentPos();

		var cls:ClassType = Context.getLocalClass().get();
		var fields:Array<Field> = Context.getBuildFields();

		fields = fields.concat([
			{
				name: "customData",
				access: [Access.APublic],
				kind: FieldType.FVar(macro :Dynamic, macro $v
					{
						{}
					}),
				pos: pos
			}
		]);

		return fields;
	}
}