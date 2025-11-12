package crow.logics.templates;

import crow.logics.templates.Template;

class TweenTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		return [
			"create_tween" => ExecutableAction.createAction((ctx) ->
			{
				final tweenName:String = ctx.values.name;
				final tweenProps:Dynamic = ctx.values.props;
				final duration:Null<Float> = ctx.values.duration;


				// TODO: I disallowed structures, find another way to do options.
				final tweenOptions:TweenOptions = {onComplete: (_)->ctx.onComplete};

				ExecutableAction.handleEntityAction(ctx.targetedEntities, (entity) ->
				{
					// TODO: Allow targeting specific sprites within an entity.
					ctx.executor.tweenManager.tween(tweenName, entity, tweenProps, duration, tweenOptions);
				});
			}, [
					{name: "name", type: "String", optional: false},
					{name: "props", type: "Dynamic", optional: false},
					{name: "duration", type: "Float", optional: false},
			], {wantsExecutor: true, wantsTargetedEntities: true}),
			"cancel_tween" => ExecutableAction.createAction((ctx) ->
			{
				final tweenName:String = ctx.values.name;
				if (tweenName != null)
					ctx.executor.tweenManager.remove(tweenName);
				ctx.onComplete();
			}, [{name: "name", type: "String", optional: false}], {wantsExecutor: true})
		];
	}
}
