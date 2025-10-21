package gear.assets;

import haxe.ds.StringMap;

/**
 * A simple cache for storing assets.
 */
class AssetCache
{
	/**
	 * Whether the cache is enabled.
	 */
	public var enabled:Bool = true;

	private var _cache:StringMap<Dynamic> = new StringMap<Dynamic>();

	public function new() {}

	/**
	 * Checks if an asset with the given ID exists in the cache.
	 */
	public function has(id:String):Bool
	{
		return enabled && _cache.exists(id);
	}

	/**
	 * Retrieves an asset from the cache.
	 */
	public function get(id:String):Dynamic
	{
		return _cache.get(id);
	}

	/**
	 * Adds or updates an asset in the cache.
	 */
	public function set(id:String, data:Dynamic):Void
	{
		if (enabled)
		{
			_cache.set(id, data);
		}
	}

	/**
	 * Removes an asset from the cache.
	 */
	public function remove(id:String):Void
	{
		if (enabled)
		{
			_cache.remove(id);
		}
	}

	/**
	 * Clears all assets from the cache.
	 */
	public function clear():Void
	{
		if (enabled)
		{
			_cache = new StringMap<Dynamic>();
		}
	}

	public function toString():String
	{
		var list:Array<String> = [];
		for (key in _cache.keys())
		{
			list.push('$key: ${_cache.get(key)}');
		}
		return list.join('\n');
	}

	public function toStringMinimal():String
	{
		var list:Array<String> = [];
		for (key in _cache.keys())
		{
			list.push('$key');
		}
		return list.join(', ');
		
	}
}