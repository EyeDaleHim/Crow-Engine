package crow.ecs.components.data;

import crow.assets.metadata.levels.GameStemData;
import crow.ecs.components.BaseComponent;

/**
 * This component just holds GameStemData, it's initialized through 
 * the constructor so that you do not need to create GameStemData.
 */
class LoadLevelComponent extends BaseComponent
{
	public var gameStem:GameStemData;

	public function new(level:String = null, playlist:String = null)
	{
		gameStem = {
			level: level != null ? Main.levels.getLevel(level) : null,
			playlist: playlist != null ? new Playlist(Main.levels.getPlaylistContent(playlist).map(Main.levels.getLevel)) : null
		};
	}

	override function get_trait():ComponentTrait
	{
		return ComponentTrait.Single;
	}
}
