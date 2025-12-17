package crow.logics.templates;

import crow.ecs.components.ModelComponent;
import crow.logics.templates.Template;

class AnimationTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		return [
			"play_animation" => ExecutableAction.createAction((ctx) ->
			{
				final animName:String = ctx.values.anim;

				final force:Bool = ctx.values.force ?? false;
				final updateHitbox:Bool = ctx.values.updateHitbox ?? true;
				final updateLayoutPosition:Bool = ctx.values.updateLayoutPosition ?? true;
				ExecutableAction.handleEntityAction(ctx.targetedEntities, (entity) ->
				{
					final modelComp = entity.getComponentByType(ModelComponent);
					if (modelComp == null)
						return;

					final model = (cast modelComp : ModelComponent).model;
					if (model == null)
						return;

					// TODO: Filters for sprites within entities?
					model.forEachOfType(FlxSprite, (spr) ->
					{
						spr.animation.play(animName, force);
						if (ctx.localState != null)
						{
							// TODO: This might still be inaccurate in some cases, find solutions later!
							if (ctx.localState.get("compensate"))
							{
								spr.animation.update(ctx.localState.get("catchupMs") / 1000);
							}
						}
						if (updateHitbox)
							spr.updateHitbox();
						if (updateLayoutPosition)
						{
							if (entity.layoutTarget != null && entity.metadata.layoutTarget != null)
							{
								model.updateLayoutTargetPosition(entity.layoutTarget, entity.metadata.layoutTarget);
							}
						}
					});
				});
			}, [
					{name: "anim", type: "String", optional: false},
					{name: "force", type: "Bool", optional: true},
					{name: "updateHitbox", type: "Bool", optional: true},
					{name: "updateLayoutPosition", type: "Bool", optional: true}
			], {wantsTargetedEntities: true, wantsLocalState: true})
		];
	}
}
