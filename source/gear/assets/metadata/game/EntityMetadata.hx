package gear.assets.metadata.game;

import gear.utils.AxeData;
import gear.assets.metadata.display.AnimationMetadata;

typedef EntityMetadata =
{
	/**
	 * The name for this entity.
	 */
	var name:String;

	/**
	 * The list of sprites for this entity to render.
	 * 
	 * Rendering order depends on the order of elements in this array.
	 */
	var sprites:Array<SpriteMetadata>;
};

typedef SpriteMetadata =
{
	/**
	 * The name of the sprite.
	 */
	var name:String;

	/**
	 * The path to the sprite's image file.
	 */
	var assetPath:String;

	/**
	 * Whether or not this sprite uses an atlas. The default value
	 * is false.
	 */
	var ?usingAtlas:Bool;

	/**
	 * The metadata for the sprite's animation. Has no effect if
	 * usingAtlas is false.
	 */
	var ?animations:Array<AnimationMetadata>;

	/**
	 * The position of this sprite relative to its parent entity.
	 */
	var position:AxeData<Float>;

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
};
