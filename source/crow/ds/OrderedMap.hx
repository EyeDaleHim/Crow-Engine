package crow.ds;

import crow.ds.orderedmap.OrderedStringMap;
import crow.ds.orderedmap.OrderedIntMap;
import crow.ds.orderedmap.OrderedEnumValueMap;
import crow.ds.orderedmap.OrderedObjectMap;
import haxe.macro.Context;
import haxe.macro.Expr;

/**
	Represents a collection of keys and values.
	You can iterate through the keys in insertion order.

	This is a multi-type abstract, it is instantiated as one of its specialization types
	depending on its type parameters.

	@see https://github.com/DenkiYagi/extype/blob/master/src/extype/OrderedMap.hx
**/
@:transitive
@:multiType(@:followWithAbstracts K)
abstract OrderedMap<K, V>(IOrderedMap<K, V>)
{
	/**
		Creates a new forward.

		This becomes a constructor call to one of the specialization types in the output.
		The rules for that are as follows:

		1. if `K` is a `String`, `crow.ds.OrderedStringMap` is used
		2. if `K` is an `Int`, `crow.ds.OrderedIntMap` is used
		3. if `K` is an `EnumValue`, `crow.ds.OrderedEnumValueMap` is used
		4. if `K` is any other class or structure, `crow.ds.OrderedObjectMap` is used
		5. if `K` is any other type, it causes a compile-time error
	**/
	public function new();

	/**
		Returns the number of key/value pairs in this Map object.
	**/
	public var length(get, never):Int;

	inline function get_length():Int
	{
		return Lambda.count(this);
	}

	/**
		Returns the current mapping of `key`.
	**/
	public inline function get(key:K):V
	{
		return this.get(key);
	}

	/**
		Maps key to value.

		If `key` already has a mapping, the previous value disappears.

		If `key` is `null`, the result is unspecified.
	**/
	public inline function set(key:K, value:V):Void
	{
		this.set(key, value);
	}

	/**
		Returns true if key `has` a mapping, false otherwise.

		If `key` is `null`, the result is unspecified.
	**/
	public inline function exists(key:K):Bool
	{
		return this.exists(key);
	}

	/**
		Removes the mapping of key and returns true if such a mapping existed, false otherwise.

		If `key` is `null`, the result is unspecified.
	**/
	public inline function remove(key:K):Bool
	{
		return this.remove(key);
	}

	/**
		Returns an Iterator over the keys of this Map.
	**/
	public inline function keys():Iterator<K>
	{
		return this.keys();
	}

	/**
		Returns an Iterator over the values of this Map.
	**/
	public inline function iterator():Iterator<V>
	{
		return this.iterator();
	}

	/**
		Returns an Iterator over the keys and values of this Map.
	**/
	public inline function keyValueIterator():KeyValueIterator<K, V>
	{
		return this.keyValueIterator();
	}

	/**
		Returns a shallow copy of this Map.
	**/
	public inline function copy():OrderedMap<K, V>
	{
		return cast this.copy();
	}

	/**
		Returns a String representation of this Map.
	**/
	public inline function toString():String
	{
		return this.toString();
	}

	/**
		Removes all keys from this Map.
	**/
	public inline function clear():Void
	{
		this.clear();
	}

	@:to static inline function toStringMap<K:String, V>(t:IOrderedMap<K, V>):OrderedStringMap<V>
	{
		return new OrderedStringMap<V>();
	}

	@:to static inline function toIntMap<K:Int, V>(t:IOrderedMap<K, V>):OrderedIntMap<V>
	{
		return new OrderedIntMap<V>();
	}

	@:to static inline function toEnumValueMapMap<K:EnumValue, V>(t:IOrderedMap<K, V>):OrderedEnumValueMap<K, V>
	{
		return new OrderedEnumValueMap<K, V>();
	}

	@:to static inline function toObjectMap<K:{}, V>(t:IOrderedMap<K, V>):OrderedObjectMap<K, V>
	{
		return new OrderedObjectMap<K, V>();
	}

	@:from static inline function fromStringMap<V>(map:OrderedStringMap<V>):OrderedMap<String, V>
	{
		return cast map;
	}

	@:from static inline function fromIntMap<V>(map:OrderedIntMap<V>):OrderedMap<Int, V>
	{
		return cast map;
	}

	@:from static inline function fromEnumValueMap<K:EnumValue, V>(map:OrderedEnumValueMap<K, V>):OrderedMap<K, V>
	{
		return cast map;
	}

	@:from static inline function fromObjectMap<K:{}, V>(map:OrderedObjectMap<K, V>):OrderedMap<Int, V>
	{
		return cast map;
	}

	/**
		Creates a OrderedMap object from the map literal.
	**/
	public static macro function of(expr:Expr):Expr
	{
		return switch (expr.expr)
		{
			case EArrayDecl(elements):
				macro $b
				{
					[macro final map = new extype.OrderedMap()].concat(elements.map(elem ->
					{
						return switch (elem.expr)
						{
							case EBinop(OpArrow, eKey, eVal):
								macro map.set(${eKey}, ${eVal});
							case _:
								Context.error("Invalid syntax: expected a => b", elem.pos);
						}
					})).concat([macro map])
				};
			case _:
				Context.error("Invalid syntax: map literal required", expr.pos);
		}
	}
}

interface IOrderedMap<K, V> extends Map.IMap<K, V>
{
	/**
		Returns a shallow copy of this Map.
	**/
	function copy():IOrderedMap<K, V>;
}
