package crow.logics.templates;

import crow.ds.Nullable;
import crow.logics.dependencies.IEventExecutor;
import crow.logics.dependencies.LogicContext;
import crow.logics.dependencies.LogicState;
import crow.logics.evaluators.LogicEvaluator;
import crow.logics.validators.LogicValidator;
import crow.ecs.entities.Entity;

abstract class Template
{
	public abstract function actions():Map<String, ExecutableAction>;
}

typedef ActionFunction = ActionContext->Void;

@:allow(LogicEvaluator)
@:allow(LogicValidator)
class ExecutableAction
{
	public var execute:ActionFunction;
	public var fieldList:Array<Field>;
	public var requirements:Requirements;
	private var _name:String;

	public function new() {}

	public static function createAction(?func:ActionFunction, list:Array<Field>, ?reqs:Requirements):ExecutableAction
	{
		var action = new ExecutableAction();
		action.execute = func;
		action.fieldList = list;
		action.requirements = reqs != null ? Reflect.copy(reqs) : {};
		return action;
	}

	public static function handleEntityAction(entities:Array<Entity>, entityFunc:Entity->Void):Void
	{
		if (entities == null) return;
		for (entity in entities)
		{
			entityFunc(entity);
		}
	}
}

typedef ActionContext =
{
	var values:Dynamic;
	var executor:IEventExecutor;
	
	var logicContext:ILogicContext;

	// Legacy accessors (Can be deprecated later, but kept for transition)
	var executorState:LogicState; 
	var ?localState:LogicState;

	var ?targetedEntities:Array<Entity>;
	var ?onComplete:Void->Void;
}

typedef Field =
{
	var name:String;
	var type:String;
	var ?optional:Bool;
}

typedef Requirements = 
{
	var ?wantsExecutor:Bool;
	var ?wantsTargetedEntities:Bool;
	var ?wantsLocalState:Bool;
	var ?wantsOnComplete:Bool;
}

enum abstract FieldType(String) to String
{
	var TString = "String";
	var TInt = "Int";
	var TFloat = "Float";
	var TBool = "Bool";
	var TDynamic = "Dynamic";

	
	@:from
	static public function fromString(s:String):FieldType
	{
		return switch (s.toLowerCase().trim())
		{
			case "string":
				TString;
			case "int":
				TInt;
			case "float":
				TFloat;
			case "bool":
				TBool;
			case "dynamic":
				TDynamic;
			default:
				throw 'Unknown FieldType: $s';
		}
	}
	
}