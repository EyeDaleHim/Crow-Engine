package crow.logics.templates;

import crow.assets.metadata.logics.ActionMetadata;
import crow.logics.evaluators.ActionEvaluator;
import crow.logics.templates.Template;

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
						ActionEvaluator.evaluate(stateChange, ctx.executorState, ctx.localState, entity.logicState);
					});
				}
				else
					ActionEvaluator.evaluate(stateChange, ctx.executorState, ctx.localState);
				ctx.onComplete();
			},
				[{name: "state", type: "ActionMetadata", optional: false}]),

			"dispatch_event" => ExecutableAction.createAction((ctx) ->
			{
				if (ctx.executor == null)
				{
					trace('Executor required for this action: dispatch_event');
					return;
				}

				final eventName:String = ctx.values.name;
				if (eventName == null)
				{
					trace('Event name not provided for dispatch_event action.');
					return;
				}
				final eventArgs:LogicState = ctx.values.args;
				ctx.executor.onEvent(eventName, eventArgs);
				ctx.onComplete();
			}, [
					{name: "name", type: "String", optional: false},
					{name: "args", type: "LogicState", optional: true}
			]),
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
			}, [{name: "tag", type: "String", optional: false}]),
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
			}, [{name: "scene", type: "String", optional: false}])
		];
	}
}
