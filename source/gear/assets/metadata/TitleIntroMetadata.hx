package gear.assets.metadata;

/**
 * Defines the structure for the title screen intro, including beat-timed events
 * and a list of random text pairs to be chosen from.
 */
typedef TitleIntroMetadata =
{
	/**
	 * An array of text pairs. One pair will be chosen at random when the intro starts.
	 * The `useRandomText` action will then reference lines from this chosen pair.
	 */
	var ?randomTextPairs:Array<Array<String>>;

	/**
	 * The sequence of events that occur on specific beats.
	 */
	var beatEvents:Array<TitleBeatEvent>;
};
/**
 * An event that occurs on a specific beat during the title screen intro.
 */
typedef TitleBeatEvent =
{
	/**
	 * The beat on which this event should trigger.
	 */
	var beat:Int;

	/**
	 * An array of actions to perform on this beat.
	 */
	var actions:Array<TitleAction>;

	/**
	 * If true, the screen will flash white and the intro will not play again.
	 */
	var ?killIntro:Bool;
};

/**
 * An action to be performed as part of a `TitleBeatEvent`.
 * Only one of the optional fields should be used per action.
 */
typedef TitleAction =
{
	/**
	 * Use a line from the pre-selected random text pair.
	 * `0` for the first line, `1` for the second.
	 * This action will replace any existing text.
	 */
	var ?useRandomText:Int;

	/**
	 * An array of strings to display on the screen. Each string is a new line of text.
	 * This will replace any existing text.
     * 
     * This takes priority over `setRandomText`.
	 */
	var ?setText:Array<String>;

	/**
	 * A string to add as a new line of text below the existing text.
	 */
	var ?addText:String;

	/**
	 * If true, all text currently on screen will be removed.
	 */
	var ?wipeText:Bool;

	/**
	 * Defines a sprite to be shown or hidden. You can only have one sprite at a time.
	 */
	var ?associationSprite:AssociationSprite;
};

typedef AssociationSprite =
{
	/**
	 * The key associated with this sprite.
     * 
     * If not null, the game will have the sprite load the graphic.
	 */
	var ?key:String;

	/**
	 * The visibility associated with this sprite.
	 */
	var visible:Bool;
};
