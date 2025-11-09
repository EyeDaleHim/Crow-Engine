package crow.logics.templates;

import crow.logics.templates.Template;

class TimerTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		return [
			"create_timer" => ExecutableAction.createAction((ctx) ->
			{
				if (ctx.executor == null)
				{
					trace('Executor required for this action: create_timer');
					return;
				}

				final timerName:String = ctx.values.name;
				final time:Null<Float> = ctx.values.time;

				if (timerName == null || time == null)
				{
					if (timerName == null)
					{
						trace('Invalid arguments for create_timer: name is required.');
					}
					else if (time == null)
					{
						trace('Invalid arguments for create_timer: time is required.');
					}
					else
					{
						trace('Invalid arguments for create_timer: name and time are required.');
					}
					return;
				}

				ctx.executor.timerManager.wait(timerName, time, ctx.onComplete);
			}, [
					{name: "name", type: "String", optional: false},
					{name: "time", type: "Float", optional: false}
			]),
			"cancel_timer" => ExecutableAction.createAction((ctx) ->
			{
				if (ctx.executor == null)
				{
					trace('Executor required for this action: cancel_timer');
					return;
				}
				final timerName:String = ctx.values.name;
				if (timerName != null)
					ctx.executor.timerManager.remove(timerName);
				ctx.onComplete();
			}, [{name: "name", type: "String", optional: false}])
		];
	}
}
