package crow.logics.templates;

import crow.logics.templates.Template;

class EntityTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		return [
			"destroy_entity" => ExecutableAction.createAction((ctx) ->
			{
				ExecutableAction.handleEntityAction(ctx.targetedEntities, (entity) ->
				{
					if (ctx.executor != null && ctx.executor.entities.exists(entity.entityName))
					{
						entity.destroy();
						ctx.executor.entities.remove(entity.entityName); // Remove from map after destroying
					}
				});
				ctx.onComplete();
			}, [], {wantsTargetedEntities: true, wantsExecutor: true})
		];
	}
}
