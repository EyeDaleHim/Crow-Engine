package crow.assets.metadata.scenes;

/**
 * The root that this gameplay scene starts with.
 * 
 * Usually, the default is enough, providing the classic
 * 4-key strum line, health bar, health icons, and notes.
 * 
 * Unlike other metadatas, inheritance is much more limited here.
 */
typedef RootPlayMetadata = {};

/**
 * The metadata for a group of lanes.
 */
typedef LaneGroup =
{
	/**
	 * The starting position of this strum line, in top-left.
	 */
	var position:AxeData<Float>;

	/**
	 * The spacing between each strum item.
	 */
	var spacing:AxeData<Float>;

	/**
	 * The list of lanes to create for this lane group.
	 */
	var list:Array<Lane>;
};

/**
 * The visual data for this lane, decides the
 * visuals for both the note object and strum object.
 */
typedef Lane =
{
	/**
	 * The strum to load.
	 */
	var strumDataPath:String;
    
    /**
     * The note to load.
     */
    var noteDataPath:String;

    /**
     * The number of pixels a note travels per millisecond.
     * This is used to calculate the scroll speed of notes.
     */
    var pixelsPerMs:Float;

	/**
	 * The angle of where the note comes from, in degrees.
	 */
	var laneAngle:Float;

	/**
	 * The distance from the strum that notes will spawn in.
	 * Uses song position and is measured in milliseconds.
	 */
	var spawnDistance:Float;
};
