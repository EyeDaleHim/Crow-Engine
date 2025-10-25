package gear.assets.metadata.game;

import gear.utils.AxeData;
import gear.utils.ColorData;
import flixel.util.FlxColor;
import gear.assets.metadata.display.AnimationMetadata;

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
	 * The list of sprites for this entity to render.
	 * 
	 * Rendering order depends on the order of elements in this array.
	 */
	var sprites:Array<SpriteMetadata>;
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
	 * The difference between this method's `color` and the `color` field in `SpriteMetadata` is that this `color` 
	 * field applies a tint to the entire sprite after it has been loaded or created, whereas the `color` in 
	 * here is used to define the base color of a `graphic` type sprite.
	 */
	var ?color:ColorData;
};

typedef SpriteMetadata =
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
	var ?color:ColorData;
};
