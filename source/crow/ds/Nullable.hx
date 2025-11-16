package crow.ds;

import haxe.ds.Option;

abstract Nullable<T>(Null<T>)
{
	inline function new(x:Null<T>)
	{
		this = x;
	}

	@:from
	public static inline function of<T>(x:Null<T>):Nullable<T>
	{
		return new Nullable(x);
	}

	@:to
	public inline function toMaybe():Maybe<T>
	{
		return if (nonEmpty())
		{
			Some(this);
		}
		else
		{
			None;
		}
	}

	public static inline function fromMaybe<T>(x:Maybe<T>):Nullable<T>
	{
		return switch (x)
		{
			case Some(v): Nullable.of(v);
			case None: null;
		}
	}

	@:to
	public inline function toOption():Option<T>
	{
		return if (nonEmpty())
		{
			Some(this);
		}
		else
		{
			None;
		}
	}

	public static inline function fromOption<T>(x:Option<T>):Nullable<T>
	{
		return switch (x)
		{
			case Some(v): Nullable.of(v);
			case None: null;
		}
	}

	public inline function get():Null<T>
	{
		return this;
	}

	public inline function getUnsafe():T
	{
		return this;
	}

	public inline function getOrElse(x:T):T
	{
		return if (nonEmpty())
		{
			this;
		}
		else
		{
			x;
		}
	}

	public inline function orElse(x:Nullable<T>):Nullable<T>
	{
		return if (nonEmpty())
		{
			Nullable.of(this);
		}
		else
		{
			x;
		}
	}

	public inline function isEmpty():Bool
	{
		return this == null;
	}

	public inline function nonEmpty():Bool
	{
		return this != null;
	}

	public inline function iter(fn:(value:T) -> Void):Void
	{
		if (nonEmpty())
			fn(this);
	}

	public inline function foreach(fn:(value:T) -> Bool):Void
	{
		if (nonEmpty())
			fn(this);
	}

	public inline function map<U>(fn:(value:T) -> U):Nullable<U>
	{
		return if (nonEmpty())
		{
			fn(this);
		}
		else
		{
			null;
		}
	}

	public inline function flatMap<U>(fn:(value:T) -> Nullable<U>):Nullable<U>
	{
		return if (nonEmpty())
		{
			fn(this);
		}
		else
		{
			null;
		}
	}

	public inline function has(value:T):Bool
	{
		return nonEmpty() && this == value;
	}

	public inline function exists(fn:T->Bool):Bool
	{
		return nonEmpty() && fn(this);
	}

	public inline function find(fn:T->Bool):Null<T>
	{
		return nonEmpty() && fn(this) ? this : null;
	}

	public inline function filter(fn:(value:T) -> Bool):Nullable<T>
	{
		return if (nonEmpty() && fn(this))
		{
			this;
		}
		else
		{
			null;
		}
	}

	public inline function fold<U>(ifEmpty:Void->U, fn:(value:T) -> U):U
	{
		return if (nonEmpty())
		{
			fn(this);
		}
		else
		{
			ifEmpty();
		}
	}

	public inline function match(fn:T->Void, ifEmpty:Void->Void):Void
	{
		if (nonEmpty())
		{
			fn(this);
		}
		else
		{
			ifEmpty();
		}
	}
}
