package crow.assets.metadata.levels;

import crow.assets.metadata.scenes.PlayMetadata;
import crow.game.levels.Level;
import crow.game.levels.Playlist;

/**
 * The field that PlayState to be loaded in.
 */
typedef GameStemData =
{
	var ?level:Level;
	var ?playlist:Playlist;

	var ?scene:PlayMetadata;
};
