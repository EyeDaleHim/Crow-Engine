package crow.assets.metadata.internals;

/**
 * An internal file containing the sorted order of content.
 */
typedef MasterListMetadata =
{
	/**
	 * The ordered list of LevelGroup IDs to display (e.g. in Freeplay).
	 */
	var ?groups:Array<String>;

	/**
	 * Defines ordered playlists (e.g. Story Mode Weeks).
	 */
	var ?playlists:Array<PlaylistDefMetadata>;
};

typedef PlaylistDefMetadata =
{
    /**
     * The unique ID of the playlist (e.g., "story_mode_week1").
     */
    var id:String;

    /**
     * The list of IDs contained in this playlist.
     * Can be LevelGroup IDs or specific Level IDs.
     */
    var content:Array<String>;
}