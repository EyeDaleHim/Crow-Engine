package states.debug.game;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxTiledSprite;
import openfl.display.BitmapData;
import music.Song;
import objects.notes.Note;
import backend.graphic.CacheManager;

class ChartEditorState extends MusicBeatState
{
	public static final CELL_SIZE:Int = 45;
	public static final noteAnimations:Array<String> = ['noteLEFT', 'noteDOWN', 'noteUP', 'noteRIGHT'];

	public var gridTemplate:BitmapData; // for copying

	public static var lastPos:Float = 0.0;

	private var background:FlxSprite;

	public var mainCamera:FlxCamera;
	public var hudCamera:FlxCamera;

	public var topBar:FlxSprite;

	public var strumLines:Array<FlxTiledSprite> = [];
	public var noteSelector:FlxSprite;

	public var infoText:EditorText;

	public var camFollow:FlxObject;

	override function create()
	{
		Main.fps.alpha = 0.2;
		@:privateAccess
		for (outline in Main.fps.outlines)
			outline.alpha = 0.2;

		CacheManager.freeMemory(BITMAP, true);

		mainCamera = new FlxCamera();

		hudCamera = new FlxCamera();
		hudCamera.bgColor.alpha = 0;

		FlxG.cameras.reset(mainCamera);
		FlxG.cameras.add(hudCamera, false);

		background = new FlxSprite().loadGraphic(Paths.image('_debug/background'));
		background.antialiasing = false;
		background.alpha = 0.3;
		background.active = false;
		background.setGraphicSize(FlxG.width, FlxG.height);
		background.updateHitbox();
		background.scrollFactor.set();
		add(background);

		topBar = new FlxSprite().makeGraphic(FlxG.width, 32, FlxColor.BLACK);
		topBar.alpha = 0.6;
		topBar.active = false;
		topBar.camera = hudCamera;
		add(topBar);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter();

		if (Song.currentSong == null)
			Song.loadSong('tutorial', 'hard');

		Conductor.changeBPM(Song.currentSong.bpm);

		FlxG.sound.music.loadEmbedded(Paths.inst(Song.currentSong.song), true);
		FlxG.sound.music.play();
		FlxG.sound.music.pause();

		Conductor.songPosition = lastPos;

		FlxG.mouse.visible = true;

		new Note();

		noteSelector = new FlxSprite();
		noteSelector.frames = switch (Note._noteFile.atlasType)
		{
			case 'packer':
				Paths.getPackerAtlas('game/ui/noteSkins/${Song.metaData.noteSkin}/${Note.currentSkin}');
			default:
				Paths.getSparrowAtlas('game/ui/noteSkins/${Song.metaData.noteSkin}/${Note.currentSkin}');
		}

		for (animData in Note._noteFile.animationData)
		{
			if (animData.indices != null && animData.indices.length > 0)
				noteSelector.animation.addByIndices(animData.name, animData.prefix, animData.indices, "", animData.fps, animData.looped);
			else
				noteSelector.animation.addByPrefix(animData.name, animData.prefix, animData.fps, animData.looped);
		}

		gridTemplate = FlxGridOverlay.createGrid(CELL_SIZE, CELL_SIZE, CELL_SIZE * 2, CELL_SIZE * 16, true, 0xffd9e2e6, 0xffa8a1a1);

		gridTemplate.lock();
		for (y in 0...4)
		{
			for (x in 0...gridTemplate.width)
			{
				gridTemplate.setPixel32(x, gridTemplate.height - y, FlxColor.BLACK);
			}
		}
		gridTemplate.unlock();

		for (i in 0...2)
		{
			var strumLine:FlxTiledSprite = new FlxTiledSprite(gridTemplate, gridTemplate.width * 2, (FlxG.sound.music.length / Conductor.stepCrochet) * CELL_SIZE);
			strumLine.x = 50 + ((CELL_SIZE + 4) * (i * 4));

			strumLines.push(strumLine);
			add(strumLine);
		}

		noteSelector.attributes.set('sineAlpha', 0.0);
		noteSelector.attributes.set('sineSpeed', 1.5);

		add(noteSelector);

		infoText = new EditorText();

		FlxG.camera.follow(camFollow, null, 1);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			super.update(elapsed);

			persistentUpdate = false;
			MusicBeatState.switchState(new PlayState());

			return;
		}

		var songControl:Bool = songMovementController();
		var sectionControl:Bool = sectionMovementController();

		for (strum in strumLines)
		{
			if ((FlxG.mouse.x > strum.x && FlxG.mouse.x < strum.x + strum.width) && (FlxG.mouse.y > strum.y && FlxG.mouse.y < strum.y + strum.height))
			{
				noteSelector.visible = true;

				noteSelector.setGraphicSize(CELL_SIZE, CELL_SIZE);
				noteSelector.updateHitbox();
				
				noteSelector.setPosition(Math.floor(FlxG.mouse.x / CELL_SIZE) * CELL_SIZE, Math.floor(FlxG.mouse.y / CELL_SIZE) * CELL_SIZE);
			}
			else
				noteSelector.visible = false;
		}

		if (Conductor.songPosition < 0 || Conductor.songPosition >= FlxG.sound.music.length)
			Conductor.songPosition = 0;

		lastPos = Conductor.songPosition;

		if (songControl || sectionControl)
			FlxG.sound.music.pause();
		else if (BindKey.getKey(TOGGLE_SONG, JUST_PRESSED))
		{
			FlxG.sound.music.time = Conductor.songPosition;

			if (FlxG.sound.music.playing)
				FlxG.sound.music.pause();
			else
				FlxG.sound.music.resume();
		}

		if (FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;

		if (noteSelector.visible)
		{
			noteSelector.attributes['sineAlpha'] += elapsed * noteSelector.attributes['sineSpeed'];
			noteSelector.alpha = 1 - Math.sin(noteSelector.attributes['sineAlpha'] / Math.PI) * 0.5;
		}

		camFollow.y = Tools.lerpBound(camFollow.y,
			FlxMath.remapToRange(Conductor.songPosition, 0, FlxG.sound.music.length, strumLines[0].y, strumLines[0].y + strumLines[0].height), 35 * elapsed);

		super.update(elapsed);
	}

	private function songMovementController():Bool
	{
		var pressedUp:Bool = BindKey.getKey(SONG_UP, PRESSED);
		var pressedDown:Bool = BindKey.getKey(SONG_DOWN, PRESSED);

		if (pressedUp || pressedDown)
		{
			var speed:Float = BindKey.getKey(MULTIPLY_BIND, PRESSED) ? -4 : -1;

			if (pressedDown)
				speed *= -1;

			Conductor.songPosition += FlxG.elapsed * (speed * 1500);
		}

		return (pressedUp || pressedDown);
	}

	private function sectionMovementController():Bool
	{
		var pressedLeft:Bool = BindKey.getKey(SECTION_UP, JUST_PRESSED);
		var pressedRight:Bool = BindKey.getKey(SECTION_DOWN, JUST_PRESSED);

		if (pressedLeft || pressedRight)
		{
			var speed:Float = BindKey.getKey(MULTIPLY_BIND, PRESSED) ? -2 : -1;

			if (pressedRight)
				speed *= -1;

			Conductor.songPosition += Conductor.stepCrochet * 16 * speed;
		}

		return (pressedLeft || pressedRight);
	}

	override public function destroy()
	{
		Main.fps.alpha = 1.0;
		@:privateAccess
		for (outline in Main.fps.outlines)
			outline.alpha = 1.0;

		Note._noteFile = null;

		super.destroy();
	}
}

class EditorText extends FlxText
{
	public static var DEFAULT_FONT:String = Paths.font("vcr.ttf");

	public override function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
	{
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
		font = DEFAULT_FONT;
	}
}

enum abstract BindKey(Int)
{
	var SONG_UP:BindKey = 0;
	var SONG_DOWN:BindKey = 1;
	var TOGGLE_SONG:BindKey = 2;
	var SECTION_DOWN:BindKey = 3;
	var SECTION_UP:BindKey = 4;
	var MULTIPLY_BIND:BindKey = 5;

	public static function getKey(bind:BindKey, state:backend.data.Controls.State):Bool
	{
		var actualControl:Dynamic = null;
		var fromList:Bool = false;

		var controlInstance = Controls.instance.LIST_CONTROLS;
		switch (bind)
		{
			case SONG_UP:
				actualControl = controlInstance["UI_UP"];
				fromList = true;
			case SONG_DOWN:
				actualControl = controlInstance["UI_DOWN"];
				fromList = true;
			case SECTION_UP:
				actualControl = controlInstance["UI_LEFT"];
				fromList = true;
			case SECTION_DOWN:
				actualControl = controlInstance["UI_RIGHT"];
				fromList = true;
			case TOGGLE_SONG:
				actualControl = [FlxKey.SPACE];
				fromList = false;
			case MULTIPLY_BIND:
				actualControl = [FlxKey.SHIFT];
				fromList = false;
			case _:
		}

		if (actualControl == null)
			return false;

		return fromList ? switch (state)
		{
			case JUST_PRESSED:
				actualControl.justPressed();
			case PRESSED:
				actualControl.pressed();
			case JUST_RELEASED:
				actualControl.justReleased();
			case RELEASED:
				actualControl.released();
		} : switch (state)
			{
				case JUST_PRESSED:
					FlxG.keys.anyJustPressed(actualControl);
				case PRESSED:
					FlxG.keys.anyPressed(actualControl);
				case JUST_RELEASED:
					FlxG.keys.anyJustReleased(actualControl);
				case RELEASED:
					FlxG.keys.anyPressed(actualControl) == false;
			};
	}
}
