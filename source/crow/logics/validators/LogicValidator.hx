package crow.logics.validators;

import crow.logics.templates.Template.ActionContext;
import crow.logics.templates.Template.ExecutableAction;

/**
 * A utility class for validating the execution context of a logic action against its requirements.
 */
class LogicValidator
{
	/**
	 * Validates if the provided action context satisfies the requirements of the executable action.
	 *
	 * @param executable The action with its defined requirements.
	 * @param context The execution context.
	 * @return `true` if the context is valid, `false` otherwise.
	 */
	public static function validate(executable:ExecutableAction, context:ActionContext):Bool
	{
		if (executable.requirements == null)
			return true; // No requirements to validate against.

		final reqs = executable.requirements;

		if (reqs.wantsExecutor == true && context.executor == null)
		{
			trace('Logic validation failed: Action requires an executor, but none was provided.');
			return false;
		}

		if (reqs.wantsTargetedEntities == true && context.targetedEntities == null)
		{
			trace('Logic validation failed: Action requires targeted entities, but none were provided.');
			return false;
		}

		if (reqs.wantsLocalState == true && context.localState == null)
		{
			trace('Logic validation failed: Action requires local state, but none was provided.');
			return false;
		}

		if (reqs.wantsOnComplete == true && context.onComplete == null)
		{
			trace('Logic validation failed: Action requires an onComplete callback, but none was provided.');
			return false;
		}

		if (executable.fieldList != null)
		{
			for (field in executable.fieldList)
			{
				final value = Reflect.field(context.values, field.name);

				// Check for missing non-optional fields
				if (value == null && field.optional != true)
				{
					trace('Logic validation failed: Missing required field "${field.name}".');
					return false;
				}

				// If field is present, validate its type
				if (value != null)
				{
					if (!checkType(value, field.type))
					{
						final valueType = Type.typeof(value);
						trace('Logic validation failed: Field "${field.name}" has incorrect type. Expected ${field.type}, but got ${valueType}.');
						return false;
					}
				}
			}
		}

		return true;
	}

	private static function checkType(value:Dynamic, typeName:String):Bool
	{
		switch (typeName)
		{
			case "String":
				return Std.isOfType(value, String);
			case "Int":
				return Std.isOfType(value, Int);
			case "Float":
				// Allow Int to be used where Float is expected
				return Std.isOfType(value, Float) || Std.isOfType(value, Int);
			case "Bool":
				return Std.isOfType(value, Bool);
			case "Dynamic":
				return true;
			default:
				// Structured types are not supported for validation.
				trace('Logic validation failed: Unsupported type "${typeName}" for validation.');
				return false;
		}
	}
}