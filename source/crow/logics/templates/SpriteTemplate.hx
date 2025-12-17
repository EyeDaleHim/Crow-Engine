package crow.logics.templates;

import crow.logics.templates.Template;

class SpriteTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		return [
			"set_alpha" => ExecutableAction.createAction((ctx) ->
			{
				final alpha:Float = ctx.values.alpha;
				ExecutableAction.handleModelAction(ctx.targetedEntities, (model) -> model.alpha = alpha);
				ctx.onComplete();
			}, [{name: "alpha", type: "Float", optional: false}], {wantsTargetedEntities: true}),
			"set_visible" => ExecutableAction.createAction((ctx) ->
			{
				final visible:Bool = ctx.values.visible;
				ExecutableAction.handleModelAction(ctx.targetedEntities, (model) -> model.visible = visible);
				ctx.onComplete();
			}, [{name: "visible", type: "Bool", optional: false}], {wantsTargetedEntities: true})
		];
	}
}
