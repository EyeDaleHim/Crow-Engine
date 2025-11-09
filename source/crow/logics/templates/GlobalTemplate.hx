package crow.logics.templates;

import crow.logics.templates.Template;

class GlobalTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		return [
			"open_url" => ExecutableAction.createAction((ctx) ->
			{
				final url:String = ctx.values.url;
				if (url != null)
					FlxG.openURL(url);
				ctx.onComplete();
			}, [{name: "url", type: "String", optional: false}]),
			"exit_game" => ExecutableAction.createAction((ctx) ->
			{
				final code:Int = ctx.values.code != null ? ctx.values.code : 0;
				Sys.exit(code);
				ctx.onComplete();
			}, [{name: "code", type: "Int", optional: true}])
		];
	}
}
