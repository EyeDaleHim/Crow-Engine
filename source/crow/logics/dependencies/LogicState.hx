package crow.logics.dependencies;

import crow.ds.Set;

/**
 * A dynamic state object that stores key-value pairs, with support for restricted keys.
 *
 * Restricted keys can only be set by the `setRestricted` method and cannot be overwritten
 * by the standard `set` method. This is useful for protecting game-critical state variables
 * from being accidentally modified by data-driven logic.
 * 
 * Only the game's code itself can mark a value as restricted.
 */
class LogicState extends haxe.ds.StringMap<Dynamic>
{
	/**
	 * The name for this LogicState, doesn't do anything useful
	 * on its own but very nice for debugging.
	 */
	public var name:String = "undefined";

	/**
	 * Keys only the game should write to, data files will
	 * not be able to write to them.
	 * 
	 * Uses red-black tree.
	 */
	public var restrictedKeys:Set<String>;

	/**
	 * Whether this LogicState is allowed to mark a value as
	 * read-only or not. This acts as a regular StringMap otherwise.
	 */
	public var allowRestriction:Bool = false;

	public function new(name:String)
	{
		super();
		this.name = name;
		restrictedKeys = new Set<String>();
	}

	/**
	 * Sets a value for the given key, but only if the key is not restricted.
	 * @param key The key to set.
	 * @param value The value to set.
	 */
	override public function set(key:String, value:Dynamic):Void
	{
		if (restrictedKeys.contains(key) && allowRestriction)
		{
			trace('WARNING: Attempted to write to restricted key "$key". Operation ignored.');
			return;
		}
		super.set(key, value);
	}

	/**
	 * Sets a value for the given key, marking the key as restricted.
	 * @param key The key to set.
	 * @param value The value to set.
	 */
	public function setRestricted(key:String, value:Dynamic):Void
	{
		if (allowRestriction)
			restrictedKeys.add(key);

		super.set(key, value);
	}

	/**
	 * Removes a key-value pair from the state, and also removes it from the restricted list.
	 * @param key The key to remove.
	 * @return If the key was present and successfully removed.
	 */
	override public function remove(key:String):Bool
	{
		if (allowRestriction)
			restrictedKeys.remove(key);
		return super.remove(key);
	}

	/**
	 * Clears all key-value pairs from the state, and clears the restricted keys list.
	 */
	override public function clear():Void
	{
		if (allowRestriction)
			restrictedKeys.clear();
		super.clear();
	}
}
