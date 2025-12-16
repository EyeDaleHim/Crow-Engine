package crow.logics.evaluators;

import crow.assets.metadata.logics.LogicMetadata;
import crow.ds.orderedmap.OrderedStringMap;
import crow.logics.dependencies.IEventExecutor;
import crow.logics.dependencies.LogicContext;
import crow.logics.dependencies.LogicState;
import crow.logics.templates.*;
import crow.logics.templates.Template;
import crow.logics.tools.ActionScope;
import crow.logics.tools.EntityFilter;
import crow.logics.tools.StringInterpolator;
import crow.logics.tools.ValidatorLevel;
import crow.logics.validators.LogicValidator;

class LogicEvaluator
{
	public static final globalState:LogicState = new LogicState("_global");

	public static var validationLevel:ValidatorLevel = REQUIRED;

	public static final jumpTables:Map<String, ExecutableAction> = [];

	public static function init():Void
	{
		globalState.allowRestriction = true;
		globalState.setRestricted("gameWidth", FlxG.width);
		globalState.setRestricted("gameHeight", FlxG.height);
		globalState.setRestricted("songListLength", Main.levels.groups.count());

		var list:Array<Class<Template>> = [
			ActionTemplate,
			AnimationTemplate,
			CameraTemplate,
			ComponentTemplate,
			EntityTemplate,
			GlobalTemplate,
			MusicTemplate,
			MenuTemplate,
			SoundTemplate,
			SpriteTemplate,
			TextTemplate,
			TimerTemplate,
			TweenTemplate
		];

		for (item in list)
		{
			var template = Type.createEmptyInstance(item);
			for (name => action in template.actions())
			{
				if (jumpTables.exists(name))
					throw 'Action "$name" already exists.';
				@:privateAccess action._name = name;
				jumpTables.set(name, action);
			}
		}
	}

	/**
	 * Executes a list of actions.
	 */
	public static function execute(actions:Array<ListenerActionMetadata>, executorState:LogicState, ?localState:LogicState,
			?entities:OrderedStringMap<Entity>, ?executor:IEventExecutor):Void
	{
		var ctx = LogicContext.createLegacy(executorState, localState);
		executeContext(actions, ctx, entities, executor);
	}

	/**
	 * Executes actions using the new LogicContext system.
	 */
	public static function executeContext(actions:Array<ListenerActionMetadata>, logicContext:LogicContext, ?entities:OrderedStringMap<Entity>,
			?executor:IEventExecutor):Void
	{
		for (action in actions)
		{
			final targetedEntities:Array<Entity> = if (entities != null)
			{
				if (action.targets != null)
					EntityFilter.filterEntities(entities, action.targets);
				else
					[for (entity in entities) entity];
			}
			else null;

			// Context Swap for Entity Scope during Interpolation
			// If exactly one entity is targeted, we register it as "entity" scope for this action's interpolation
			if (targetedEntities != null && targetedEntities.length == 1)
			{
				logicContext.register(crow.logics.tools.ActionScope.ENTITY, targetedEntities[0].logicState);
			}
			else
			{
				logicContext.unregister(crow.logics.tools.ActionScope.ENTITY);
			}

			// Interpolate Values
			final values:Dynamic = {};
			if (action.values != null && Reflect.isObject(action.values))
			{
				for (field in Reflect.fields(action.values))
				{
					final val:Dynamic = Reflect.field(action.values, field);
					if (Std.isOfType(val, String))
					{
						Reflect.setField(values, field, StringInterpolator.interpolate(cast val, logicContext));
					}
					else
					{
						Reflect.setField(values, field, val);
					}
				}
			}

			final postEvents = action.postListenerEvents;
			final onComplete = (postEvents != null) ? () ->
			{
				executeContext(postEvents, logicContext, entities, executor);
			} : () -> {};

			final actionType = action.type.trim();
			if (jumpTables.exists(actionType))
			{
				final executable = jumpTables.get(actionType);

				// Re-extract specific states for legacy compatibility in ActionContext
				var execState = logicContext.getState(GLOBAL);
				var locState = logicContext.getState(LOCAL);

				final context:ActionContext = {
					values: values,
					logicContext: logicContext, // New System
					executorState: execState, // temp
					localState: locState, // temp
					targetedEntities: targetedEntities,
					executor: executor,
					onComplete: onComplete
				};

				switch (validationLevel)
				{
					case REQUIRED:
						if (!LogicValidator.validate(executable, context))
							continue;
					case WARN:
						LogicValidator.validate(executable, context);
					case NONE:
				}
				executable.execute(context);
			}
			else
			{
				trace('WARNING: Unknown action type: ${action.type}');
			}
		}
	}
}
