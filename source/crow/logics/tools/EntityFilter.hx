package crow.logics.tools;

import crow.assets.metadata.game.EntityMetadata;
import crow.assets.metadata.logics.LogicMetadata;
import crow.entities.Entity;
import flixel.FlxG;
import flixel.util.FlxStringUtil;
import Type;

/**
 * A utility class for filtering entities based on metadata criteria.
 */
class EntityFilter
{
	/**
	 * Filters a list of entities based on an array of filter criteria.
	 * The filters are applied sequentially.
	 *
	 * @param allEntities The initial map of all entities to be filtered.
	 * @param filters An array of `EntityFilterMetadata` objects.
	 * @return An array of entities that match all filter criteria.
	 */
	public static function filterEntities(allEntities:Map<String, Entity>, filters:Array<EntityFilterMetadata>):Array<Entity>
	{
		if (filters == null || filters.length == 0)
		{
			return [];
		}

		// Convert map values to an array to start
		var candidates:Array<Entity> = [for (entity in allEntities) entity];
        candidates.sort((a, b) -> Reflect.compare(a.ID, b.ID));

		for (filter in filters)
		{
			// Apply each filter to the current list of candidates
			candidates = candidates.filter(entity -> matches(entity, filter));
		}

		return candidates;
	}

	/**
	 * Checks if a single entity matches a given filter.
	 *
	 * @param entity The entity to check.
	 * @param filter The filter criteria.
	 * @return `true` if the entity matches, otherwise `false`.
	 */
	private static function matches(entity:Entity, filter:EntityFilterMetadata):Bool
	{
		if (filter.name != null && entity.entityName != filter.name)
		{
			return false;
		}

		if (filter.tag != null)
		{
			// Assuming Entity has a `tags:Array<String>` field.
			// This part may need adjustment based on the actual implementation of tags.
			final entityTags:Array<String> = entity.tags;
			if (entityTags == null || entityTags.indexOf(filter.tag) == -1)
			{
				return false;
			}
		}

		if (filter.type != null)
		{
			final entityMetrics = entity.membersMetricsMap.get(entity.entityName);
			if (entityMetrics == null || entityMetrics.type != filter.type)
			{
				return false;
			}
			
		}

		return true;
	}
}