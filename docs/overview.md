### Logic System Architecture Overview

Crow Engine's logic system provides a flexible, data-driven way to manage game state and execute actions. It is built around a few core concepts:

1.  **State Management (`LogicState`)**: A simple key-value store that holds all game state, from global flags to entity-specific properties.
2.  **Conditions (`PredicateMetadata`)**: A declarative, JSON-friendly structure for defining complex logical conditions (e.g., `(score > 100 AND has_key == true) OR is_invincible == true`).
3.  **Actions (`ActionMetadata` & `ListenerActionMetadata`)**: A declarative structure for defining state changes (e.g., `INCREMENT score by 1`) and game events (e.g., `play_animation "run"`).
4.  **Evaluation and Execution**: A set of static "evaluator" classes that interpret the metadata structures to read state, evaluate conditions, and execute actions.

This design allows game logic to be defined in external data files (like JSON), making it easy to modify without recompiling code.

Keep in mind while this is very powerful, these data files can often get verbose, in some cases, modifying the source code
can become necessary in niche cases.

---

### Core Data Structures

#### `LogicState`

This is the backbone of the state management system. It is a map where keys are `String` identifiers and values can be of any `Dynamic` type, allowing for flexible storage of numbers, strings, booleans, and even lists.

```haxe
// source\crow\logics\LogicState.hx
typedef LogicState = haxe.ds.StringMap<Dynamic>;
```

There are typically four scopes of state:

*   **Global State**: All values are persistent until the game ends.
*   **Executor State**: The values for that stated are tied to the executor.
*   **Local State**: Temporary state, often for a specific event or interaction.
*   **Entity State**: State specific to a single game entity.

The order of states is as follows:
*   LOCAL > GLOBAL > ENTITY
*   For STATIC, you will have to explicitly define in your files to use it.

---

### Predicate System (Conditional Logic)

The predicate system is used to ask questions about the current game state. It evaluates conditions and returns `true` or `false`.

#### `PredicateMetadata`

This `typedef` defines a single logical condition or a combination of conditions. Its recursive nature allows for building complex logical trees.

```haxe
// source\crow\assets\metadata\logics\PredicateMetadata.hx
typedef PredicateMetadata =
{
	// The type of logical operation.
	var type:PredicateType; // e.g., "AND", "CHECK", "STATE_COMPARE"

	// For "AND", "OR", "NOT": a list of nested predicates.
	var ?operands:Array<PredicateMetadata>;

	// The state scope to check.
	var ?scope:ActionScope; // e.g., "global", "entity"

	// The state variable to check.
	var ?stateKey:String;

	// The comparison operator.
	var ?operatorCode:PredicateOperatorCode; // e.g., "EQ", "GT"

	// The value(s) to compare against.
	var ?targetValues:Array<Dynamic>;
}
```

#### `PredicateType`

An enumeration of all possible logical operations. This defines the fundamental building blocks for conditions.

```haxe
// source\crow\logics\PredicateType.hx
enum abstract PredicateType(String)
{
	// Logical Combinators
	var AND;           // All operands must be true.
	var OR;            // At least one operand must be true.
	var NOT;           // Inverts the result of its operand.

	// State Checks
	var CHECK;         // Compares a state value against a target value.
	var LIST_CONTAINS; // Checks if a value exists in a state list.
	var STATE_COMPARE; // Compares two state values against each other.

	// Dynamic Checks
	var RANGED_RANDOM; // A random number check.
}
```

#### `PredicateOperatorCode`

An enumeration of comparison operators used within a `CHECK` or `STATE_COMPARE` predicate.

The order of values like comparators like `GT` and `LTE` typically compare the first value against the other, therefore:

The predicate will return `true` if `value[0]` >= `value[1]`. This distinction is important.

```haxe
// source\crow\logics\PredicateOperatorCode.hx
enum abstract PredicateOperatorCode(String)
{
	var EQ;     // Equal
	var NEQ;    // Not Equal
	var GT;     // Greater Than
	var LT;     // Less Than
	var GTE;    // Greater Than or Equal
	var LTE;    // Less Than or Equal
	var MODULO; // Modulo operation
}
```

---

### Action System (State Modification & Events)

The action system is used to make changes to the game state or trigger game events.

#### `ActionMetadata`

This `typedef` defines a single, atomic change to a value within a `LogicState`. It is the core component for state modification.

```haxe
// source\crow\assets\metadata\logics\ActionMetadata.hx
typedef ActionMetadata =
{
	// The type of change to perform.
	var changeType:ActionChangeType; // e.g., "SET", "INCREMENT"

	// The state variable to modify.
	var stateKey:String;

	// The value to use for the modification.
	var ?value:Dynamic;

	// The state scope to modify.
	var ?scope:ActionScope; // e.g., "global", "local", "entity"
};
```

#### `ActionChangeType`

An enumeration of all possible ways a state variable can be modified.

```haxe
// source\crow\logics\ActionChangeType.hx
enum abstract ActionChangeType(String)
{
	var SET;        // Set a value directly.
	var INCREMENT;  // Add an integer value.
	var DECREMENT;  // Subtract an integer value.
	var ADD;        // Add a float value.
	var SUBTRACT;   // Subtract a float value.
	var MULTIPLY;   // Multiply by a float value.
	var DIVIDE;     // Divide by a float value.
	var TOGGLE;     // Invert a boolean value.
}
```

#### `ActionScope`

An enumeration defining the different state containers that an action or predicate can target.

The priority of scopes in evaluators is as follows:
LOCAL > ENTITY > GLOBAL


```haxe
// source\crow\logics\ActionScope.hx
enum abstract ActionScope(String)
{
	var GLOBAL; // The global game state.
	var LOCAL;  // A temporary, event-specific state.
	var ENTITY; // The state attached to a specific entity.
}
```

---

### Evaluators and Executors

These are the "brains" of the system. They are static classes that take the metadata structures as input and perform the actual work.

*   **`PredicateEvaluator`**: Takes a `PredicateMetadata` object and the current states (`global`, `local`, `entity`) and returns a `Bool` indicating if the condition is met.
*   **`PredicateValidator`**: A utility that can be run before `PredicateEvaluator` to ensure a `PredicateMetadata` object is structured correctly, preventing runtime errors.
*   **`ActionEvaluator`**: Takes an `ActionMetadata` object and the states, then modifies the appropriate `LogicState` map according to the action's definition.
*   **`LogicEvaluator`**: A higher-level executor that processes a list of generic actions (`ListenerActionMetadata`). It can perform `state_change` actions (using `ActionEvaluator`), but also handles a wide range of game events like playing animations, creating tweens, dispatching events, and controlling the camera by interacting with an `IEventExecutor`.
*   **`EntityFilter`**: A utility used by `LogicEvaluator` to select which entities an action should apply to, based on criteria like name, tag, or type.

### `IEventExecutor` Interface

This interface defines the contract for a class that can execute "side-effect" actions that go beyond simple state changes. It acts as a bridge between the abstract logic system and the concrete game engine implementation (e.g., a `FlxState`).

```haxe
// source\crow\logics\IEventExecutor.hx
interface IEventExecutor
{
    // Managers for time-based operations
    public var timerManager:TimerManager;
    public var tweenManager:TweenManager;

    // State and scene management
    public var logicState:LogicState;
    public function switchScene(sceneName:String):Bool;

    // Event system hooks
    public function onEvent(eventName:String, ?args:LogicState):Void;
    public function removeListenersByTag(tag:String):Void;

    // Access to game systems
    public var music:Music;
}
```

This structured, data-oriented approach provides a powerful and maintainable foundation for building complex game logic.