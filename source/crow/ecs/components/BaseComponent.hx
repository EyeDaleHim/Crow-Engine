package crow.ecs.components;

abstract class BaseComponent implements IComponent
{
	public var entity(default, set):Entity;

	function set_entity(value:Entity):Entity
	{
		return this.entity = value;
	}

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

	/**
	 * The name of the component. Must be unique.
	 */
	public var name(get, default):String;

	function get_name():String
	{
		if (name == null)
			name = crow.utils.UUID.generateV4();
		return name;
	}

	public function destroy():Void
	{
		this.entity = null;
		this.name = null;
	}
}

interface IComponent
{
	public var entity(default, set):Entity;

	public var trait(get, never):ComponentTrait;
    public var customTrait:String;

	public function destroy():Void;

    private function get_trait():ComponentTrait;

	public var name(get, default):String;

	private function get_name():String;
}

@:transitive
@:forward
abstract ComponentTrait(UInt) from UInt to UInt
{
	/**
	 * If a component does not need to inhabit these traits, for custom behavior.
	 */
	public static inline var None = 0x0;

	/**
	 * Remove this component after it has been processed.
	 */
	public static inline var Weak = 0x1;

	/**
	 * Allow components of the same type to be added multiple times to an entity.
	 */
	public static inline var Multi = 0x2;

	/**
	 * Allow only one component of the same type to be added to an entity.
	 */
	public static inline var Single = 0x4;

	/**
	 * Like Single, but replaces the same component of this type if it already exists.
	 */
	public static inline var Replace = 0x8;

	@:from
	static function fromUInt(value:UInt):ComponentTrait
	{
		if ((value & Multi != 0) && (value & Single != 0))
		{
			throw "Multi and Single traits are mutually exclusive.";
		}
		return new ComponentTrait(value);
	}

	@:to
	function toUInt():UInt
	{
		return this;
	}

	public function new(value:UInt)
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
		return fromUInt(this | other.toUInt());
	}

	public inline function has(flag:ComponentTrait):Bool
	{
		return (this & flag.toUInt()) == flag.toUInt();
	}

	public inline function add(flag:ComponentTrait):ComponentTrait
	{
		return fromUInt(this | flag.toUInt());
	}

	public inline function remove(flag:ComponentTrait):ComponentTrait
	{
		return fromUInt(this & (~flag.toUInt()));
	}
}
