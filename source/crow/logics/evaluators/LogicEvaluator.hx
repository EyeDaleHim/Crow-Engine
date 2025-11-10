package crow.logics.evaluators;

import crow.assets.metadata.logics.ActionMetadata;
import crow.assets.metadata.logics.LogicMetadata;
import crow.logics.dependencies.IEventExecutor;
import crow.logics.dependencies.LogicState;
import crow.logics.templates.Template;
import crow.logics.templates.Template.ActionContext;
import crow.logics.templates.*;
import crow.logics.tools.ActionChangeType;
import crow.logics.tools.ActionScope;
import crow.logics.tools.EntityFilter;
import crow.logics.tools.StringInterpolator;
import crow.entities.AnimatedText;
import crow.utils.ColorData;

/**
 * A utility class for executing actions defined by `ListenerActionMetadata`.
 */
class LogicEvaluator
{
	public static final globalState:LogicState = new LogicState();

	public static final jumpTables:Map<String, ExecutableAction> = [];

	public static function init():Void
	{
		var list:Array<Class<Template>> = [];

		list.push(ActionTemplate);
		list.push(AnimationTemplate);
		list.push(CameraTemplate);
		list.push(EntityTemplate);
		list.push(GlobalTemplate);
		list.push(MusicTemplate);
		list.push(SoundTemplate);
		list.push(SpriteTemplate);
		list.push(TextTemplate);
		list.push(TimerTemplate);
		list.push(TweenTemplate);

		for (item in list)
		{
			var template = Type.createEmptyInstance(item);
			var actions = template.actions();

			for (name => action in actions)
			{
				if (jumpTables.exists(name))
				{
					throw 'Action with name "$name" already exists. Please use a unique name.';
				}
				jumpTables.set(name, action);
			}
		}
	}

	public static function execute(actions:Array<ListenerActionMetadata>, executorState:LogicState, ?localState:LogicState, ?entities:Map<String, Entity>,
			?executor:IEventExecutor):Void
	{
		for (action in actions)
		{
			// Interpolate string values before execution
			final values:Dynamic = {};
			if (action.values != null)
			{
				if (!Reflect.isObject(action.values))
					throw 'action.values must be an object, not an array or primitive.';

				for (field in Reflect.fields(action.values))
				{
					if (Std.isOfType(Reflect.field(action.values, field), String))
					{
						Reflect.setField(values, field, StringInterpolator.interpolate(Reflect.field(action.values, field), executorState, localState));
					}
					else
					{
						Reflect.setField(values, field, Reflect.field(action.values, field));
					}
				}
			}
			final postEvents = action.postListenerEvents;

			final onComplete = (postEvents != null && executor != null) ? () ->
			{
				execute(postEvents, executorState, localState, entities, executor);
			} : () -> {};

			final targetedEntities = (entities != null && action.targets != null) ? EntityFilter.filterEntities(entities, action.targets) : null;

			final actionType = action.type.trim();
			if (jumpTables.exists(actionType))
			{
				final executable = jumpTables.get(actionType);
				final context:ActionContext = {
					values: values,
					executorState: executorState,
					localState: localState,
					targetedEntities: targetedEntities,
					executor: executor,
					onComplete: onComplete
				};
				executable.execute(context);
				continue;
			}

			switch (actionType)
			{
				default:
					trace('WARNING: Unknown action type: ${action.type}');
			}
		}
	}

	private static function handleEntityAction(entities:Array<Entity>, entityFunc:Entity->Void):Void
	{
		if (entities == null)
			return;
		for (entity in entities)
		{
			entityFunc(entity);
		}
	}

	private static inline function getValue<T>(values:Dynamic, name:String, ?defaultValue:T):T
	{
		return Reflect.hasField(values, name) ? Reflect.field(values, name) : defaultValue;
	}
}
