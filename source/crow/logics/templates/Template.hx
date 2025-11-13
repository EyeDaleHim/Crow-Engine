package crow.logics.templates;

import crow.logics.dependencies.IEventExecutor;
import crow.logics.dependencies.LogicState;
import crow.logics.evaluators.LogicEvaluator;
import crow.logics.validators.LogicValidator;
import crow.ecs.entities.Entity;

/**
 * The base class for all executable action templates.
 * 
 * An individual template acts as a namespace for a collection of executable actions.
 */
abstract class Template
{
	/**
	 * A map containing the executable actions provided by this template.
	 */
	public abstract function actions():Map<String, ExecutableAction>;
}

typedef ActionFunction = ActionContext->Void;

@:allow(LogicEvaluator)
@:allow(LogicValidator)
class ExecutableAction
{
	/**
	 * The function to execute.
	 */
	public var execute:ActionFunction;

	/**
	 * The list of fields that this action takes.
	 * 
	 * This is merely acting as a reference for structure checkers, 
	 * to prevent misspellings and incorrect types.
	 */
	public var fieldList:Array<Field>;

	/**
	 * The requirements for the action's execution context.
	 */
	public var requirements:Requirements;

	/**
	 * The key for this action. Used internally.
	 */
	private var _name:String;

	public static function createAction(?func:ActionFunction, list:Array<Field>, ?reqs:Requirements):ExecutableAction
	{
		final action = Type.createEmptyInstance(ExecutableAction);
		action.execute = func;
		action.fieldList = list;
		action.requirements = reqs ?? {};
		return action;
	}

	public static function handleEntityAction(entities:Array<Entity>, entityFunc:Entity->Void):Void
	{
		if (entities == null)
			return;
		for (entity in entities)
		{
			entityFunc(entity);
		}
	}
}

/**
 * A structure that holds all the contextual information needed to execute a logic action.
 */
typedef ActionContext =
{
	/**
	 * The interpolated values/parameters for the action.
	 */
	final values:Dynamic;

	/**
	 * The state of the event executor.
	 */
	final executorState:LogicState;

	/**
	 * The temporary state for the current event.
	 */
	final ?localState:LogicState;

	/**
	 * The entities targeted by this action. Can be null.
	 */
	final ?targetedEntities:Array<Entity>;

	/**
	 * The executor responsible for handling engine-specific events. Can be null.
	 */
	final ?executor:IEventExecutor;

	/**
	 * A callback to be executed upon completion of an asynchronous action. Can be null.
	 */
	final ?onComplete:Void->Void;
}

typedef Field =
{
	/**
	 * The name of the field.
	 */
	var name:String;

	/**
	 * The type of the field. Only supports primitive or structure types.
	 */
	var type:String;

	/**
	 * If the field is optional.
	 */
	var ?optional:Bool;
}

typedef Requirements = 
{
	/**
	 * If the action wants the executor.
	 */
	var ?wantsExecutor:Bool;

	/**
	 * If the action wants targeted entities.
	 */
	var ?wantsTargetedEntities:Bool;

	/**
	 * If the action wants local state.
	 */
	var ?wantsLocalState:Bool;

	/**
	 * If the action wants to be able to signal completion.
	 */
	var ?wantsOnComplete:Bool;
}