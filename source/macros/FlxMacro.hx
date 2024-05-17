package macros;

class FlxMacro
{
	/**
	 * A macro to be called targeting the `FlxBasic` class.
	 * @return An array of fields that the class contains.
	 */
	public static macro function buildFlxBasic():Array<haxe.macro.Expr.Field>
	{
		var pos:haxe.macro.Expr.Position = haxe.macro.Context.currentPos();
		// The FlxBasic class. We can add new properties to this class.
		var cls:haxe.macro.Type.ClassType = haxe.macro.Context.getLocalClass().get();
		// The fields of the FlxClass.
		var fields:Array<haxe.macro.Expr.Field> = haxe.macro.Context.getBuildFields();

		fields = fields.concat([
			{
				name: "customData", // Field name.
				access: [haxe.macro.Expr.Access.APublic], // Access level
				kind: haxe.macro.Expr.FieldType.FVar(macro :Map<String, Dynamic>, macro $v{new Map<String, Dynamic>()}), // Variable type and default value
				pos: pos, // The field's position in code.
			}
		]);

		return fields;
	}
}
