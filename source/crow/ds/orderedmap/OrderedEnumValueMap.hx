package crow.ds.orderedmap;

import crow.ds.LinkedList;
import haxe.ds.EnumValueMap in StdMap;

/**
	Represents a Map object of `EnumValue` keys.
	You can iterate through the keys in insertion order.
**/
class OrderedEnumValueMap<K:EnumValue, V>
{
	final map:StdMap<K, LinkedListNode<Pair<K, V>>>;
	final list:LinkedList<Pair<K, V>>;

	/**
		Returns the number of key/value pairs in this Map object.
	**/
	public var length(get, never):Int;

	public inline function new()
	{
		this.map = new StdMap();
		this.list = new LinkedList();
	}

	/**
		Returns the current mapping of `key`.
	**/
	public inline function get(key:K):Null<V>
	{
		final node = Nullable.of(map.get(key));
		return node.map(x -> x.value.value2).get();
	}

	/**
		Maps key to value.

		If `key` already has a mapping, the previous value disappears.

		If `key` is `null`, the result is unspecified.
	**/
	public inline function set(key:K, value:V):Void
	{
		if (map.exists(key))
		{
			list.remove(map.get(key));
		}
		map.set(key, list.add(new Pair(key, value)));
	}

	/**
		Returns true if key `has` a mapping, false otherwise.

		If `key` is `null`, the result is unspecified.
	**/
	public inline function exists(key:K):Bool
	{
		return map.exists(key);
	}

	/**
		Removes the mapping of key and returns true if such a mapping existed, false otherwise.

		If `key` is `null`, the result is unspecified.
	**/
	public inline function remove(key:K):Bool
	{
		return if (map.exists(key))
		{
			list.remove(map.get(key));
			map.remove(key);
			true;
		}
		else
		{
			false;
		}
	}

	/**
		Returns an Iterator over the keys of this Map.
	**/
	public inline function keys():Iterator<K>
	{
		return new crow.ds.iterators.TransformIterator(list.iterator(), pair -> pair.value1);
	}

	/**
		Returns an Iterator over the values of this Map.
	**/
	public inline function iterator():Iterator<V>
	{
		return new crow.ds.iterators.TransformIterator(list.iterator(), pair -> pair.value2);
	}

	/**
		Returns an Iterator over the keys and values of this Map.
	**/
	public inline function keyValueIterator():KeyValueIterator<K, V>
	{
		return new crow.ds.iterators.TransformIterator(list.iterator(), pair -> new EnumKeyValue(pair.value1, pair.value2));
	}

	/**
		Returns a shallow copy of this Map.
	**/
	public inline function copy():OrderedEnumValueMap<K, V>
	{
		final newMap = new OrderedEnumValueMap();
		list.iter(pair -> newMap.set(pair.value1, pair.value2));
		return newMap;
	}

	/**
		Returns a String representation of this Map.
	**/
	public inline function toString():String
	{
		final buff = [];
		list.iter(pair -> buff.push('${pair.value1}=>${pair.value2}'));
		return '[${buff.join(",")}]';
	}

	/**
		Removes all keys from this Map.
	**/
	public inline function clear():Void
	{
		map.clear();
		list.clear();
	}

	inline function get_length():Int
	{
		return list.length;
	}
}

private class EnumKeyValue<K:EnumValue, V>
{
	public var key:K;
	public var value:V;

	public function new(key:K, value:V)
	{
		this.key = key;
		this.value = value;
	}
}
