package gear.assets.metadata;

typedef AnimationMetadata = {
    
	/**
	 * The name of the animation.
	 */
	var name:String;

	/**
	 * The prefix for the animation frames.
	 */
	var prefix:String;

	/**
	 * The frame rate of the animation.
	 */
	var ?frameRate:Int;

	/**
	 * Whether the animation should loop.
	 */
	var ?loop:Bool;

	/**
	 * The indices of the frames to use for the animation.
	 */
	var ?indices:Array<Int>;
	
}