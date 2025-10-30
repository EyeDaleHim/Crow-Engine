package crow.entities.managers;

/**
 * A generic interface for managing a collection of named objects,
 * such as tweens or timers, associated with an entity.
 * @param T The type of object being managed (e.g., FlxTween, FlxTimer).
 */
interface IManager<T>
{
	/**
	 * A map of all managed objects, keyed by their unique name.
	 */
	public var list(default, null):Map<String, T>;

	/**
	 * Adds a new object to be managed. If an object with the same name
	 * already exists, it should be overwritten.
	 * @param name  The unique name to identify the object.
	 * @param item  The object to manage.
	 */
	public function add(name:String, item:T):Void;

	/**
	 * Retrieves an object by its name.
	 * @param name The name of the object to retrieve.
	 * @return The object if found, otherwise `null`.
	 */
	public function get(name:String):Null<T>;

	/**
	 * Removes an object from the manager by its name.
	 * @param name The name of the object to remove.
	 * @return `true` if the object was found and removed, otherwise `false`.
	 */
	public function remove(name:String):Bool;

	/**
	 * Removes and cleans up all objects from the manager.
	 */
	public function clear():Void;
}