package crow.ecs.components;

abstract class BaseComponent implements IComponent
{
	public var entity:Entity;

	/**
	 * The traits of the component.
	 * Traits are used to define how the component is processed.
	 */
	public var trait(get, never):ComponentTrait;

    function get_trait():ComponentTrait
    {
        return ComponentTrait.None;
    }

    /**
     * The custom trait of the component.
     * Leave null to use the `trait` field.
     * 
     * However, if not null, systems will use `customTrait` instead of `trait`.
     */
    public var customTrait:String;
}

interface IComponent
{
	public var entity:Entity;

	public var trait(get, never):ComponentTrait;
    public var customTrait:String;

    private function get_trait():ComponentTrait;
}

typedef OrderedComponentMap = crow.ds.OrderedMap<Class<IComponent>, Array<IComponent>>;

@:transitive
@:forward
abstract ComponentTrait(Int) from Int to Int
{
	/**
	 * If a component does not need to inhabit these traits, for custom behavior.
	 */
	public static inline var None = 0;

	/**
	 * Remove this component after it has been processed.
	 */
	public static inline var Weak = 1 << 0;

	/**
	 * Allow components of the same type to be added multiple times to an entity.
	 */
	public static inline var Multi = 1 << 1;

	/**
	 * Allow only one component of the same type to be added to an entity.
	 */
	public static inline var Single = 1 << 2;

	/**
	 * Like Single, but replaces the same component of this type if it already exists.
	 */
	public static inline var Replace = 1 << 3;

	@:from
	static function fromInt(value:Int):ComponentTrait
	{
		if ((value & Multi != 0) && (value & Single != 0))
		{
			throw "Multi and Single traits are mutually exclusive.";
		}
		return new ComponentTrait(value);
	}

	@:to
	function toInt():Int
	{
		return this;
	}

	public function new(value:Int)
	{
		if ((value & Multi != 0) && (value & Single != 0))
		{
			throw "Multi and Single traits are mutually exclusive.";
		}
		this = value;
	}

	@:op(A | B)
	function or(other:ComponentTrait):ComponentTrait
	{
		return fromInt(this | other.toInt());
	}

	public inline function has(flag:ComponentTrait):Bool
	{
		return (this & flag.toInt()) == flag.toInt();
	}

	public inline function add(flag:ComponentTrait):ComponentTrait
	{
		return fromInt(this | flag.toInt());
	}

	public inline function remove(flag:ComponentTrait):ComponentTrait
	{
		return fromInt(this & (~flag.toInt()));
	}
}
