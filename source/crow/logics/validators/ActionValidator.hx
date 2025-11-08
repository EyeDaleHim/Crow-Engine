package crow.logics.validators;

import crow.assets.metadata.logics.ActionMetadata;
import crow.logics.tools.ActionChangeType;
import crow.logics.tools.ActionScope;

/**
 * A utility class for validating the structure and basic correctness of `ActionMetadata` objects.
 */
class ActionValidator
{
    /**
     * Validates the structure of a given `ActionMetadata` object.
     * This method checks for nulls and correct types.
     *
     * @param action The `ActionMetadata` object to validate.
     * @return `true` if the action is valid, `false` otherwise.
     */
    public static function validate(action:ActionMetadata):Bool
    {
        if (action == null)
        {
            trace('Action validation failed: Action is null.');
            return false;
        }

        // Validate change type
        var changeType:ActionChangeType = try cast(action.changeType, ActionChangeType) catch (e:Dynamic) null;
        if (changeType == null)
        {
            trace('Action validation failed: Invalid change type "${action.changeType}".');
            return false;
        }

        // Validate stateKey
        if (action.stateKey == null || action.stateKey == "")
        {
            trace('Action validation failed for type ${changeType}: "stateKey" is null or empty.');
            return false;
        }

        // Validate scope if present
        if (action.scope != null)
        {
            var scope:ActionScope = try cast(action.scope, ActionScope) catch (e:Dynamic) null;
            if (scope == null)
            {
                trace('Action validation failed: Invalid scope "${action.scope}".');
                return false;
            }
        }

        // Validate value based on changeType
        switch (changeType)
        {
            case SET:
                if (action.value == null)
                {
                    trace('Action validation failed for type SET: "value" is required.');
                    return false;
                }
            case INCREMENT, DECREMENT:
                if (action.value == null)
                {
                    trace('Action validation failed for type ${changeType}: "value" is required.');
                    return false;
                }
                if (!Std.isOfType(action.value, Int))
                {
                    trace('Action validation failed for type ${changeType}: "value" must be an integer.');
                    return false;
                }
            case ADD, SUBTRACT, MULTIPLY, DIVIDE:
                if (action.value == null)
                {
                    trace('Action validation failed for type ${changeType}: "value" is required.');
                    return false;
                }
                if (!Std.isOfType(action.value, Float) && !Std.isOfType(action.value, Int))
                {
                    trace('Action validation failed for type ${changeType}: "value" must be a number (Float or Int).');
                    return false;
                }
                if (changeType == DIVIDE && action.value == 0)
                {
                    trace('Action validation failed for type DIVIDE: "value" cannot be zero.');
                    return false;
                }
            case TOGGLE:
                // Value is not used for TOGGLE, so no validation needed for it.
        }

        return true;
    }
}
