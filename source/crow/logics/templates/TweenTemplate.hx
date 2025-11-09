package crow.logics.templates;

import crow.logics.templates.Template;

class TweenTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		return [
			"create_tween" => ExecutableAction.createAction((ctx) ->
			{
				if (ctx.executor == null)
				{
					trace('Executor required for this action: create_tween');
					return;
				}

				final tweenName:String = ctx.values.name;
				final tweenProps:Dynamic = ctx.values.props;
				final duration:Null<Float> = ctx.values.duration;

				if (tweenName == null || tweenProps == null || duration == null)
				{
					trace('Invalid arguments for create_tween: name, properties, and duration are required.');
					return;
				}

				final tweenOptions:Dynamic = ctx.values.options != null ? ctx.values.options : {};
				if (ctx.onComplete != null)
					tweenOptions.onComplete = ctx.onComplete;

				ExecutableAction.handleEntityAction(ctx.targetedEntities, (entity) ->
				{
					// TODO: Allow targeting specific sprites within an entity.
					ctx.executor.tweenManager.tween(tweenName, entity, tweenProps, duration, tweenOptions);
				});
			}, [
					{name: "name", type: "String", optional: false},
					{name: "props", type: "Dynamic", optional: false},
					{name: "duration", type: "Float", optional: false},
					{name: "options", type: "Dynamic", optional: true}
			]),
			"cancel_tween" => ExecutableAction.createAction((ctx) ->
			{
				if (ctx.executor == null)
				{
					trace('Executor required for this action: cancel_tween');
					return;
				}
				final tweenName:String = ctx.values.name;
				if (tweenName != null)
					ctx.executor.tweenManager.remove(tweenName);
				ctx.onComplete();
			}, [{name: "name", type: "String", optional: false}])
		];
	}
}
