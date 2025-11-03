package crow.assets.metadata.game;

import flixel.util.FlxAxes;
import crow.utils.AxeData;
import crow.utils.ColorData;
import crow.assets.metadata.display.AnimationMetadata;

typedef EntityMetadata =
{
	/**
	 * The name for this entity.
	 */
	var name:String;

	/**
	 * Whether the entity is visible on creation. Defaults to true.
	 */
	var ?visible:Bool;

	/**
	 * Defines an internal object to be used as a reference for layouts.
	 * If specified, layouts will use this object's properties (position, size) for calculations
	 * instead of the entity's own bounding box.
	 * 
	 * For example, the entity constantly changes sizes, which can make the layout's configuration
	 * inconsistent, you would use this field to resolve such cases.
	 */
	var ?layoutTarget:LayoutTargetData;

	/**
	 * The list of objects for this entity to render.
	 * 
	 * Rendering order depends on the order of elements in this array.
	 */
	var objects:Array<EntityObject>;
};

/**
 * Metadata for an entity's internal layout target.
 */
typedef LayoutTargetData =
{
	/**
	 * The width of the layout target.
	 */
	var ?width:Float;

	/**
	 * The height of the layout target.
	 */
	var ?height:Float;

	/**
	 * The position of the layout target relative to the entity's origin.
	 */
	var ?position:AxeData<Null<Float>>;
	
	/**
	 * Assuming `position` doesn't satisfy your needs, this field will force
	 * the entity to be positioned relative to the center of the layout target.
	 */
	var ?relativeToCenter:AxeData<Null<Bool>>;
};

/**
 * A container for different types of objects that can be part of an entity.
 * The `type` field determines the structure of the `data` field.
 */
typedef EntityObject =
{
	/**
	 * The type of the object. Can be "sprite", "animated_text", etc.
	 */
	var type:EntityType;

	/**
	 * The data for the object, which varies based on the `type`.
	 * 
	 * This only contains fields unique to that data.
	 */
	var data:Dynamic;
	
	/**
	 * If the object has antialiasing, this option determines whether the
	 * object is rendered with antialiasing or not.
	 * 
	 * If undefined, the value of antialiasing is determined by the player's
	 * antialiasing setting.
	 */
	var ?antialiasing:Bool;
}

/**
 * Metadata for a static text object.
 */
typedef TextObjectData =
{
	/**
	 * The name of the text object.
	 */
	var name:String;

	/**
	 * The text content to display.
	 */
	var ?text:UnicodeString;

	/**
	 * The path to the font file.
	 * 
	 * If empty, it uses Flixel's default font.
	 */
	var ?font:String;

	/**
	 * The size of the font.
	 */
	var ?size:Int;

	/**
	 * The color of the text.
	 */
	var ?color:ColorData;

	/**
	 * The position of this object relative to its parent entity.
	 */
	var ?position:AxeData<Float>;

	/**
	 * The width of the text field. If 0, it will automatically adjust.
	 */
	var ?fieldWidth:Float;

	/**
	 * The alignment of the text.
	 */
	var ?alignment:TextAlignment;

	/**
	 * The scroll factor of this object.
	 */
	var ?scrollFactor:AxeData<Float>;
	
};

/**
 * Metadata for an animated text object.
 */
typedef AnimatedTextObjectData =
{
	/**
	 * The name of the animated text object.
	 */
	var name:String;

	/**
	 * The path to the animated font's JSON file.
	 */
	var font:String;

	/**
	 * The text content to display.
	 */
	var ?text:UnicodeString;

	/**
	 * The position of this object relative to its parent entity.
	 */
	var ?position:AxeData<Float>;

	/**
	 * The width of the text field. If 0, it will automatically adjust.
	 */
	var ?fieldWidth:Float;

	/**
	 * The alignment of the text.
	 */
	var ?alignment:TextAlignment;

	/**
	 * The scroll factor of this object.
	 */
	var ?scrollFactor:AxeData<Float>;
}

/**
 * Metadata for a nested entity object.
 */
typedef NestedEntityObjectData =
{
	/**
	 * The name of this nested entity instance.
	 */
	var name:String;

	/**
	 * The path to the entity's JSON file, relative to `assets/entities/`.
	 */
	var entityFile:String;

	/**
	 * The position of this nested entity relative to its parent.
	 */
	var ?position:AxeData<Float>;

	/**
	 * The scale of this nested entity.
	 */
	var ?scale:AxeData<Float>;

	/**
	 * The scroll factor of this nested entity.
	 */
	var ?scrollFactor:AxeData<Float>;
};

/**
 * Defines how a sprite's graphic should be loaded or created. This is a base
 * type; the `type` field determines which other fields are available.
 *
 * Available types:
 * - `simple`: Loads a single image.
 *   - `path`: `String` - The path to the image file.
 * - `atlas`: Loads from a texture atlas.
 *   - `path`: `String` - The path/prefix for the texture atlas files.
 * - `graphic`: Creates a solid-colored rectangle.
 *   - `width`: `Int`
 *   - `height`: `Int`
 *   - `color`: `FlxColor`
 */
typedef SpriteAssetMethod =
{
	/**
	 * The type of asset method. Can be "simple", "atlas", or "graphic".
	 */
	var type:String;

	/**
	 * The path to the asset file. Used by `simple` and `atlas` types.
	 */
	var ?path:String;

	/**
	 * The width of the graphic. Used by the `graphic` type.
	 */
	var ?width:Int;
	/**
	 * The height of the graphic. Used by the `graphic` type.
	 */
	var ?height:Int;

	/**
	 * The color of the graphic. Used by the `graphic` type.
	 * 
	 * The difference between this method's `color` and the `color` field in `SpriteMetadata` is that the latter 
	 * applies a tint to the entire sprite after it has been loaded or created, whereas the `color` in 
	 * here is used to define the base color of a `graphic` type sprite.
	 */
	var ?color:Dynamic;
};

typedef SpriteObjectData =
{
	/**
	 * The name of the sprite.
	 */
	var name:String;

	/**
	 * The method used to load or create the sprite's graphic.
	 */
	var method:SpriteAssetMethod;

	/**
	 * The metadata for the sprite's animation. Has no effect if
	 * the method type is not "atlas".
	 */
	var ?animations:Array<AnimationMetadata>;

	/**
	 * The animation to play when this sprite is initialized.
	 * 
	 * If the animation is not found, no animation will be played.
	 */
	var ?startingAnimation:String;

	/**
	 * The position of this sprite relative to its parent entity.
	 * 
	 * If left blank, it will default to its parent entity's position.
	 */
	var ?position:AxeData<Float>;

	/**
	 * The scale of this sprite. Width and height will be updated.
	 */
    var ?scale:AxeData<Float>;

	/**
	 * The scroll factor of this sprite.
	 * 
	 * Default is (1, 1) which implies it scrolls at the same rate as the camera.
	 */
	var ?scrollFactor:AxeData<Float>;

	/**
	 * The rotation of this sprite, in degrees.
	 */
    var ?angle:Float;

	/**
	 * The color tint of this sprite.
	 */
	var ?color:Dynamic;
};

enum abstract EntityType(String) from String to String
{
	var SPRITE = "sprite";
	var TEXT = "text";
	var ANIMATED_TEXT = "animated_text";
	var NESTED_ENTITY = "nested_entity";
}
