package crow.logics.evaluators;

import crow.assets.metadata.logics.LogicMetadata;
import crow.ds.OrderedMap;
import crow.logics.dependencies.IEventExecutor;
import crow.logics.dependencies.LogicState;
import crow.logics.templates.*;
import crow.logics.templates.Template;
import crow.logics.templates.Template.ActionContext;
import crow.logics.tools.EntityFilter;
import crow.logics.tools.StringInterpolator;
import crow.logics.tools.ValidatorLevel;
import crow.logics.validators.LogicValidator;

/**
 * A utility class for executing actions defined by `ListenerActionMetadata`.
 */
class LogicEvaluator
{
	public static final globalState:LogicState = new LogicState();

	/**
	 * Requires executable actions to have their context validated before execution.
	 *
	 * Disabling this may provide a minor performance benefit at the cost of safety.
	 */
	public static var validationLevel:ValidatorLevel = REQUIRED;

	public static final jumpTables:Map<String, ExecutableAction> = [];

	public static function init():Void
	{
		var list:Array<Class<Template>> = [];

		globalState.allowRestriction = true;
		
		globalState.setRestricted("gameWidth", FlxG.width);
		globalState.setRestricted("gameHeight", FlxG.height);

		list.push(ActionTemplate);
		list.push(AnimationTemplate);
		list.push(CameraTemplate);
		list.push(ComponentTemplate);
		list.push(EntityTemplate);
		list.push(GlobalTemplate);
		list.push(MusicTemplate);
		list.push(MenuTemplate);
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
				@:privateAccess
				action._name = name; // Feels stupid to assign this way?
				jumpTables.set(name, action);
			}
		}
	}

	public static function execute(actions:Array<ListenerActionMetadata>, executorState:LogicState, ?localState:LogicState, ?entities:OrderedMap<String, Entity>,
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

			final targetedEntities:Array<Entity> = if (entities != null)
			{
				if (action.targets != null)
					EntityFilter.filterEntities(entities, action.targets);
				else
					[for (entity in entities) entity]; // If targets are omitted, apply to all entities.
			}
			else
			{
				null;
			};

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

				switch (validationLevel)
				{
					case REQUIRED:
						if (!LogicValidator.validate(executable, context))
						{
							continue; // Skip execution if validation fails
						}
					case WARN:
						LogicValidator.validate(executable, context); // Trace warnings but don't stop execution
					case NONE: // Do nothing
				}
				executable.execute(context);
				continue;
			}
			
			trace('WARNING: Unknown action type: ${action.type}');
		}
	}
}
