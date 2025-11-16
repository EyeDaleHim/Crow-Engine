package crow.ecs.components;

import crow.ds.Set;
import crow.ecs.components.BaseComponent;

/**
 * A component that contains unique tags.
 * Used to identify entities.
 */
class TagComponent extends BaseComponent
{
    public var tags:Set<String>;

    /**
     * Creates a new TagComponent.
     * @param tags An optional array of initial tags.
     */
    public function new(?tags:Array<String>)
    {
        // Set.fromArray handles null/empty input safely
        this.tags = Set.fromArray(tags ?? []);
    }

    /**
     * Adds a single tag to the component's set.
     * @param tag The string tag to add.
     * @return True if the tag was newly added, false if it already existed.
     */
    public function add(tag:String):Bool
    {
        return tags.add(tag);
    }

    /**
     * Removes a single tag from the component's set.
     * @param tag The string tag to remove.
     * @return True if the tag was present and removed, false otherwise.
     */
    public function remove(tag:String):Bool
    {
        return tags.remove(tag);
    }

    /**
     * Checks if the component contains a specific tag.
     * @param tag The string tag to check for.
     * @return True if the tag is present, false otherwise.
     */
    public function has(tag:String):Bool
    {
        return tags.contains(tag);
    }

    /**
     * Checks if the component contains ALL of the specified tags.
     * @param tagsToCheck An array of string tags to check.
     * @return True if all tags in the array are present, false otherwise.
     */
    public function hasAll(tagsToCheck:Array<String>):Bool
    {
        for (tag in tagsToCheck)
        {
            if (!tags.contains(tag))
            {
                return false;
            }
        }
        return true;
    }

    /**
     * Checks if the component contains ANY of the specified tags.
     * @param tagsToCheck An array of string tags to check.
     * @return True if at least one tag in the array is present, false otherwise.
     */
    public function hasAny(tagsToCheck:Array<String>):Bool
    {
        for (tag in tagsToCheck)
        {
            if (tags.contains(tag))
            {
                return true;
            }
        }
        return false;
    }

    /**
     * Clears all tags from the component.
     */
    public function clear():Void
    {
        tags.clear();
    }

    override function get_trait():ComponentTrait
    {
        return ComponentTrait.Single;
    }
}