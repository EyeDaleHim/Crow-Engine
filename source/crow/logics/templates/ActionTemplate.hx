package crow.logics.templates;

import crow.assets.metadata.logics.ActionMetadata;
import crow.logics.dependencies.LogicState;
import crow.logics.evaluators.ActionEvaluator;
import crow.logics.templates.Template;
import crow.logics.tools.ActionScope;

class ActionTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		return [
			"state_change" => ExecutableAction.createAction((ctx) ->
			{
				final stateChange:ActionMetadata = ctx.values.state;

				if (stateChange.scope == ENTITY)
				{
					ExecutableAction.handleEntityAction(ctx.targetedEntities, (entity) ->
					{
						var entityScopes = ctx.scopes.copy();
						entityScopes.set(ENTITY, entity.logicState);

						ActionEvaluator.evaluate(stateChange, entityScopes);
					});
				}
				else
				{
					ActionEvaluator.evaluate(stateChange, ctx.scopes);
				}

				ctx.onComplete();
			}, [], {wantsTargetedEntities: true}),

			"dispatch_event" => ExecutableAction.createAction((ctx) ->
			{
				final eventName:String = ctx.values.name;
				var eventArgs:LogicState = null;
				if (ctx.values.actions != null && Reflect.isObject(ctx.values.actions))
				{
					eventArgs = new LogicState("dispatch_event_args");
					for (field in Reflect.fields(ctx.values.actions))
					{
						eventArgs.set(field, Reflect.field(ctx.values.actions, field));
					}
				}
				eventArgs ??= new LogicState("dispatch_event_args");

				ctx.executor.onEvent(eventName, eventArgs);
				ctx.onComplete();
			}, [
					{name: "name", type: "String", optional: false},
					// The arguments to pass with the event.
					{name: "actions", type: "Dynamic", optional: true}
			], {wantsExecutor: true}),
			"remove_listeners_by_tag" => ExecutableAction.createAction((ctx) ->
			{
				if (ctx.executor == null)
				{
					trace('Executor required for this action: remove_listeners_by_tag');
					return;
				}
				final tagToRemove:String = ctx.values.tag;
				if (tagToRemove != null)
				{
					ctx.executor.removeListenersByTag(tagToRemove);
				}
				ctx.onComplete();
			},
				[{name: "tag", type: "String", optional: false}], {wantsExecutor: true}),
			"switch_scene" => ExecutableAction.createAction((ctx) ->
			{
				if (ctx.executor == null)
				{
					trace('Executor required for this action: switch_scene');
					return;
				}
				final sceneName:String = ctx.values.scene;
				if (sceneName?.length > 0)
				{
					ctx.executor.switchScene(sceneName);
				}
				else
				{
					trace('ERROR: Scene name not provided for switch_scene action.');
				}
				ctx.onComplete();
			}, [{name: "scene", type: "String", optional: false}], {wantsExecutor: true})
		];
	}
}
