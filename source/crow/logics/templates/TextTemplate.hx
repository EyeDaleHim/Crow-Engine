package crow.logics.templates;

import crow.logics.templates.Template;

class TextTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		return [
			"set_text" => ExecutableAction.createAction((ctx) ->
			{
				final text:String = ctx.values.text != null ? ctx.values.text : "";
				ExecutableAction.handleEntityAction(ctx.targetedEntities, (entity) ->
				{
					entity.forEachOfType(AnimatedText, (textObject) -> textObject.text = text);
				});
				ctx.onComplete();
			}, [{name: "text", type: "String", optional: true}], {wantsTargetedEntities: true}),
			"add_text" => ExecutableAction.createAction((ctx) ->
			{
				final newText:String = ctx.values.text != null ? ctx.values.text : "";
				ExecutableAction.handleEntityAction(ctx.targetedEntities, (entity) ->
				{
					entity.forEachOfType(AnimatedText, (textObject) ->
					{
						textObject.text += (textObject.text == "" ? "" : "\n") + newText;
					});
				});
				ctx.onComplete();
			}, [{name: "text", type: "String", optional: true}], {wantsTargetedEntities: true}),
			"clear_text" => ExecutableAction.createAction((ctx) ->
			{
				ExecutableAction.handleEntityAction(ctx.targetedEntities, (entity) ->
				{
					entity.forEachOfType(AnimatedText, (textObject) -> textObject.text = "");
				});
				ctx.onComplete();
			}, [])
		];
	}
}
