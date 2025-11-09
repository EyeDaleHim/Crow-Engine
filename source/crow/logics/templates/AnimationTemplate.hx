package crow.logics.templates;

import crow.logics.templates.Template;

class AnimationTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		return [
			"play_animation" => ExecutableAction.createAction(function(context:ActionContext)
			{
				final animName:String = context.values.anim;

				final force:Bool = context.values.force != null ? context.values.force : false;
				final updateHitbox:Bool = context.values.updateHitbox != null ? context.values.updateHitbox : true;
				ExecutableAction.handleEntityAction(context.targetedEntities, (entity) ->
				{
					// TODO: Filters for sprites within entities?
					entity.forEachOfType(FlxSprite, (spr) ->
					{
						spr.animation.play(animName, force);
						if (context.localState != null)
						{
							// TODO: This might still be inaccurate in some cases, find solutions later!
							if (context.localState.get("compensate"))
							{
								spr.animation.update(context.localState.get("catchupMs") / 1000);
							}
						}
						if (updateHitbox)
							spr.updateHitbox();
					});
				});
			}, [
					{name: "anim", type: "String", optional: false},
					{name: "force", type: "Bool", optional: true},
					{name: "updateHitbox", type: "Bool", optional: true}
			])
		];
	}
}
