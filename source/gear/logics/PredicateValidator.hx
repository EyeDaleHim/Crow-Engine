package gear.logics;

import gear.assets.metadata.logics.PredicateMetadata;

/**
 * A utility class for validating the structure and basic correctness of `PredicateMetadata` objects.
 */
class PredicateValidator
{
    /**
     * Validates the structure of a given `PredicateMetadata` object.
     * This method checks for nulls, correct types, and appropriate operand counts
     * based on the predicate's type and operator.
     *
     * @param predicate The `PredicateMetadata` object to validate.
     * @return `true` if the predicate is valid, `false` otherwise.
     */
    public static function validate(predicate:PredicateMetadata):Bool
    {
        if (predicate == null)
        {
            trace('Predicate validation failed: Predicate is null.');
            return false;
        }

        // Validate predicate type
        var predicateType:PredicateType = try cast(predicate.type, PredicateType) catch (e:Dynamic) null;
        if (predicateType == null)
        {
            trace('Predicate validation failed: Invalid predicate type "${predicate.type}".');
            return false;
        }

        switch (predicateType)
        {
            case AND, OR:
                if (predicate.operands == null || predicate.operands.length == 0)
                {
                    trace('Predicate validation failed for type ${predicate.type}: "operands" array is null or empty.');
                    return false;
                }
                for (operand in predicate.operands)
                {
                    if (!validate(operand))
                    {
                        trace('Predicate validation failed for type ${predicate.type}: Invalid operand found.');
                        return false;
                    }
                }
                return true;

            case NOT:
                if (predicate.operands == null || predicate.operands.length != 1)
                {
                    trace('Predicate validation failed for type NOT: "operands" array must contain exactly one operand.');
                    return false;
                }
                if (!validate(predicate.operands[0]))
                {
                    trace('Predicate validation failed for type NOT: Invalid operand found.');
                    return false;
                }
                return true;

            case CHECK:
                if (predicate.stateKey == null || predicate.stateKey == "")
                {
                    trace('Predicate validation failed for type CHECK: "stateKey" is null or empty.');
                    return false;
                }

                // Validate operator code
                var operatorCode:PredicateOperatorCode = try cast(predicate.operatorCode, PredicateOperatorCode) catch (e:Dynamic) null;
                if (operatorCode == null)
                {
                    trace('Predicate validation failed for type CHECK: Invalid operator code "${predicate.operatorCode}".');
                    return false;
                }

                if (predicate.targetValues == null || predicate.targetValues.length == 0)
                {
                    trace('Predicate validation failed for type CHECK: "targetValues" array is null or empty.');
                    return false;
                }

                // Specific checks for targetValues count
                switch (operatorCode)
                {
                    case MODULO:
                        if (predicate.targetValues.length != 2)
                        {
                            trace('Predicate validation failed for MODULO operator: "targetValues" must contain exactly 2 values (divisor, expected_remainder).');
                            return false;
                        }
                    case EQ, NEQ, GT, LT, GTE, LTE:
                        if (predicate.targetValues.length != 1)
                        {
                            trace('Predicate validation failed for operator ${operatorCode}: "targetValues" must contain exactly 1 value.');
                            return false;
                        }
                    default:
                        // This default case handles any other operator codes that might be added later
                        // and assumes they require 1 target value. This might need adjustment.
                        if (predicate.targetValues.length != 1) {
                            trace('Predicate validation failed for operator ${operatorCode}: "targetValues" must contain exactly 1 value.');
                            return false;
                        }
                }
                return true;

            case RANGED_RANDOM:
                if (predicate.targetValues == null || predicate.targetValues.length < 4)
                {
                    trace('Predicate validation failed for type RANGED_RANDOM: "targetValues" must contain at least 4 values (minGen, maxGen, minCheck, maxCheck).');
                    return false;
                }
                return true;

            case LIST_CONTAINS:
                if (predicate.stateKey == null || predicate.stateKey == "")
                {
                    trace('Predicate validation failed for type LIST_CONTAINS: "stateKey" is null or empty.');
                    return false;
                }
                if (predicate.targetValues == null || predicate.targetValues.length != 1)
                {
                    trace('Predicate validation failed for type LIST_CONTAINS: "targetValues" must contain exactly 1 value to find in the list.');
                    return false;
                }
                return true;

            case STATE_COMPARE:
                if (predicate.stateKey == null || predicate.stateKey == "")
                {
                    trace('Predicate validation failed for type STATE_COMPARE: "stateKey" is null or empty.');
                    return false;
                }

                var operatorCode:PredicateOperatorCode = try cast(predicate.operatorCode, PredicateOperatorCode) catch (e:Dynamic) null;
                if (operatorCode == null)
                {
                    trace('Predicate validation failed for type STATE_COMPARE: Invalid operator code "${predicate.operatorCode}".');
                    return false;
                }

                switch(operatorCode)
                {
                    case EQ, NEQ, GT, LT, GTE, LTE:
                        // These are valid for STATE_COMPARE
                    default:
                        trace('Predicate validation failed for type STATE_COMPARE: Operator "${operatorCode}" is not supported. Only comparison operators are allowed.');
                        return false;
                }

                if (predicate.targetValues == null || predicate.targetValues.length != 1)
                {
                    trace('Predicate validation failed for type STATE_COMPARE: "targetValues" must contain exactly 1 value (the second state key for comparison).');
                    return false;
                }

                final secondKey:String = predicate.targetValues[0];
                if (secondKey == null || secondKey == "")
                {
                    trace('Predicate validation failed for type STATE_COMPARE: The second state key in "targetValues" cannot be null or empty.');
                    return false;
                }

                return true;

            default:
                // This case should ideally not be reached if predicateType is strictly validated.
                // But as a fallback, if an unknown type somehow passes, it's invalid.
                trace('Predicate validation failed: Unknown predicate type "${predicate.type}".');
                return false;
        }
    }
}