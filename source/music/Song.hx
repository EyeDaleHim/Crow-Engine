package music;

import game.SkinManager;
import music.Section.SectionInfo;

class Song
{
	public static var currentSong:SongInfo;
	public static var metaData:SongMetaChart;

	public static final chartFormats:Array<String> = ['base'];

	public static function loadSong(song:String, diff:String):SongInfo
	{
		/*try
		{*/
			var fixData:String->String = function(str:String)
			{
				return str;
			};

			var path = Paths.data('charts/' + song.toLowerCase().replace(' ', '-') + '/' + song.toLowerCase().replace(' ', '-') + '-'
				+ diff.toLowerCase());

			// do this in case i fockin add new things to the meta.json thing
			var meta:SongMetaChart = null;

			if (Assets.exists(Paths.data('charts/${song.formatToReadable()}/meta')))
				meta = Json.parse(Assets.getText(Paths.data('charts/${song.formatToReadable()}/meta')));
			if (meta != null && chartFormats.contains(meta.format))
				currentSong = backend.compat.ChartConvert.convertType(meta.format, Assets.getText(path));
			else
				currentSong = Json.parse(fixData(Assets.getText(path)));

			metaData = meta;

			if (metaData.comboSkin == null)
				metaData.comboSkin = 'default';
			if (metaData.countdownSkin == null)
				metaData.countdownSkin = 'default';
			if (metaData.noteSkin == null)
				metaData.noteSkin = 'default';

			SkinManager.parseComboSkin(metaData.comboSkin);
			SkinManager.parseCountdownSkin(metaData.countdownSkin);

			return currentSong;
		/*} catch (e)
		{
			
			FlxG.log.warn('Couldn\'t load song $song with difficulty $diffString (${Paths.data('charts/' + song.toLowerCase().replace(' ', '-') + '/' + song.toLowerCase().replace(' ', '-') + '-' + diffString.toLowerCase())})');
			trace('Catched Error loading $song-$diffString: ${e.message}');
		}*/

		return {
			song: song,
			sectionList: [
				{
					notes: [],
					length: 16,
				}
			],
			speed: 1.0,
			mustHitSections: [],
			bpmMapping: [],
			bpm: 100,
			player: 'bf',
			opponent: 'dad',
			spectator: 'gf',
			extraData: []
		};
	}
}

typedef SongMetaChart =
{
	var format:String;
	@:optional var countdownSkin:String;
	@:optional var comboSkin:String;
	@:optional var noteSkin:String;
	@:optional var defaultData:Map<String, Dynamic>;
}

typedef SongInfo =
{
	var song:String;
	var sectionList:Array<SectionInfo>;
	var mustHitSections:Array<Null<Bool>>;
	var bpmMapping:Array<{step:Int, bpm:Float}>;
	var bpm:Float;
	var speed:Float;

	@:optional var extraData:Map<String, Dynamic>;
	var player:String;
	var opponent:String;
	var spectator:String; // fancy term for gf

	@:optional var noteLength:Int; // this is not going to be parsed, just a little helper
}
