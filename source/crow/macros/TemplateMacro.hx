package crow.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.MapField;
import haxe.macro.Type;

/**
 * A macro that compiles a map of all executable actions from all templates.
 */
class TemplateMacro
{
	/**
	 * Builds a map of all template actions at compile time.
	 * @return An expression representing the map of all actions.
	 */
	public static macro function build():Expr
	{
		// Get the base type for templates
		final templateBaseType = Context.getType("crow.logics.templates.Template");
		var allActionFields:Array<MapField> = [];

		// Iterate over all classes known to the compiler
		for (classType in Context.getBuildClasses())
		{
			if (classType.isAbstract)
				continue;

			final classTypeInst = TInst(classType, []);
			if (Context.isSubtype(classTypeInst, templateBaseType))
			{
				// This class is a template, so let's find its `actions` method.
				for (field in classType.fields.get())
				{
					if (field.name == "actions" && field.kind == FFun)
					{
						final funcExpr = field.expr();
						if (funcExpr == null)
							continue;

						switch (funcExpr.expr)
						{
							case EFunction(_, f):
								final mapFields = findMapExpr(f.expr);

								if (mapFields != null)
								{
									allActionFields = allActionFields.concat(mapFields);
								}
							default:
						}
						break; // Found actions method
					}
				}
			}
		}

		// Construct the final map expression
		return {expr: EMap(allActionFields), pos: Context.currentPos()};
	}

	private static function findMapExpr(e:Expr):Null<Array<MapField>>
	{
		if (e == null)
			return null;
		switch (e.expr)
		{
			case EMap(mapFields):
				return mapFields;
			case EReturn(subExpr):
				return findMapExpr(subExpr);
			case EBlock(exprs):
				for (expr in exprs)
				{
					final result = findMapExpr(expr);
					if (result != null)
						return result;
				}
			default:
		}
		return null;
	}
}