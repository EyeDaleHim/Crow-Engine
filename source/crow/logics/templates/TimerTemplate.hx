package crow.logics.templates;

import crow.logics.templates.Template;

class TimerTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		return [
			"create_timer" => ExecutableAction.createAction((ctx) ->
			{
				final timerName:String = ctx.values.name;
				final time:Null<Float> = ctx.values.time;
				ctx.executor.timerManager.wait(timerName, time, ctx.onComplete);
			}, [
					{name: "name", type: "String", optional: false},
					{name: "time", type: "Float", optional: false}
			], {wantsExecutor: true}),
			"cancel_timer" => ExecutableAction.createAction((ctx) ->
			{
				final timerName:String = ctx.values.name;
				if (timerName != null)
					ctx.executor.timerManager.remove(timerName);
				ctx.onComplete();
			}, [{name: "name", type: "String", optional: false}], {wantsExecutor: true})
		];
	}
}
