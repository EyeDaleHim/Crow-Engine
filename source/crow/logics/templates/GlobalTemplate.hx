package crow.logics.templates;

import crow.logics.templates.Template;
import openfl.net.URLRequest;

class GlobalTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		return [
			"open_url" => ExecutableAction.createAction((ctx) ->
			{
				var url:String = ctx.values.url;
				var target:String = ctx.values.target ?? "_blank";
				if (url != null)
				{
					// Only allow http and https protocols for security.
					// If no protocol is specified, default to https.
					if (!~/(^https?:\/\/)/i.match(url))
					{
						url = "https://" + url;
					}
					else
					{
						trace('HTTPS only - will not open non-https url');
					}
					openfl.Lib.getURL(new URLRequest(url), target);
				}
				ctx.onComplete();
			}, [
					{name: "url", type: "String", optional: false},
					{name: "target", type: "String", optional: true}
			]),
			"exit_game" => ExecutableAction.createAction((ctx) ->
			{
				final code:Int = ctx.values.code != null ? ctx.values.code : 0;
				Sys.exit(code);
				ctx.onComplete();
			}, [{name: "code", type: "Int", optional: true}])
		];
	}
}
