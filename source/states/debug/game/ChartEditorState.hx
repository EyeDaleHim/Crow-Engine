package states.debug.game;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxPool;
import flixel.system.FlxSound;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxTiledSprite;
import openfl.display.BitmapData;
import music.Song;
import objects.notes.Note;
import backend.graphic.CacheManager;
import sys.FileSystem;

class ChartEditorState extends MusicBeatState
{
	public static final CELL_SIZE:Int = 45;

	public static final noteAnimations:Array<String> = ['purpleScroll', 'blueScroll', 'greenScroll', 'redScroll'];
	public static final singAnimations:Array<String> = ['noteLEFT', 'noteDOWN', 'noteUP', 'noteRIGHT'];

	public var mouseState:MouseState = NORMAL;

	public static var current:ChartEditorState;

	public var gridTemplate:BitmapData; // for copying

	public static var lastPos:Float = 0.0;

	public var vocals:FlxSound;

	private var background:FlxSprite;

	public var mainCamera:FlxCamera;
	public var hudCamera:FlxCamera;

	public var topBar:FlxSprite;

	public var renderedNotes:FlxTypedGroup<ChartNote>;

	public var strumLines:Array<FlxTiledSprite> = [];
	public var noteSelector:FlxSprite;

	public var infoText:EditorText;

	public var strum:FlxSprite;

	override function create()
	{
		Main.fps.alpha = 0.2;
		@:privateAccess
		for (outline in Main.fps.outlines)
			outline.alpha = 0.2;

		current = this;

		CacheManager.freeMemory(BITMAP, true);

		mainCamera = new FlxCamera();

		hudCamera = new FlxCamera();
		hudCamera.bgColor.alpha = 0;

		FlxG.cameras.reset(mainCamera);
		FlxG.cameras.add(hudCamera, false);

		strum = new FlxSprite().makeGraphic(1, 4, 0xFF161616);

		background = new FlxSprite().loadGraphic(Paths.image('_debug/background'));
		background.antialiasing = false;
		background.alpha = 0.3;
		background.active = false;
		background.setGraphicSize(FlxG.width, FlxG.height);
		background.updateHitbox();
		background.scrollFactor.set();
		add(background);

		topBar = new FlxSprite().makeGraphic(FlxG.width, 24, FlxColor.BLACK);
		topBar.alpha = 0.6;
		topBar.active = false;
		topBar.camera = hudCamera;
		add(topBar);

		if (Song.currentSong == null)
			Song.loadSong('tutorial', 'hard');

		Conductor.changeBPM(Song.currentSong.bpm);

		FlxG.sound.music.loadEmbedded(Paths.inst(Song.currentSong.song), true);
		FlxG.sound.music.play();
		FlxG.sound.music.pause();

		vocals = new FlxSound();

		if (FileSystem.exists(Paths.vocalsPath(Song.currentSong.song)))
			vocals.loadEmbedded(Paths.vocals(Song.currentSong.song), true);
		vocals.play();
		vocals.pause();

		FlxG.sound.list.add(vocals);

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
			var strumLine:FlxTiledSprite = new FlxTiledSprite(gridTemplate, gridTemplate.width * 2,
				(FlxG.sound.music.length / Conductor.stepCrochet) * CELL_SIZE);
			strumLine.x = 50 + ((CELL_SIZE + 4) * (i * 4));
			strumLine.x += 400;

			for (i in 0...4)
			{
				strumLine.attributes.set('box$i', strumLine.x + (CELL_SIZE * i));
			}

			strumLines.push(strumLine);
			add(strumLine);
		}

		strum.x = strumLines[0].x;
		strum.scale.x = new FlxRect(strum.x, 1, gridTemplate.width * 2, 1).union(new FlxRect(strumLines[1].x, 1, gridTemplate.width * 2, 1)).width;
		strum.updateHitbox();
		strum.x = strumLines[0].x;

		noteSelector.attributes.set('sineAlpha', 0.0);
		noteSelector.attributes.set('sineSpeed', 7.5);

		renderedNotes = new FlxTypedGroup<ChartNote>();
		add(renderedNotes);

		add(strum);
		add(noteSelector);

		infoText = new EditorText("", 16);
		infoText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5, 0);
		infoText.y = FlxG.height - infoText.height - 10;
		infoText.screenCenter(X);
		infoText.camera = hudCamera;
		add(infoText);

		for (section in Song.currentSong.sectionList)
		{
			var globalID:Int = 0;
			for (note in section.notes)
			{
				var chartNote:ChartNote = new ChartNote(new Note(note.strumTime, note.direction, note.mustPress, 0, 0));
				chartNote.ID = globalID++;
				chartNote.setGraphicSize(CELL_SIZE, CELL_SIZE);
				chartNote.updateHitbox();
				chartNote.x = strumLines[note.mustPress ? 1 : 0].x + (CELL_SIZE * note.direction);
				chartNote.y = FlxMath.remapToRange(note.strumTime, 0, FlxG.sound.music.length, strumLines[0].y, strumLines[0].y + strumLines[0].height);
				renderedNotes.add(chartNote);
			}
		}

		Conductor.songPosition = lastPos;

		FlxG.camera.follow(strum, null, 1);
		FlxG.camera.targetOffset.x = 400;

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

		var songControl:Bool = songMovementCheck();
		var sectionControl:Bool = sectionMovementCheck();
		var mouseControl:Bool = mouseMovementCheck();

		if (Conductor.songPosition < 0 || Conductor.songPosition >= FlxG.sound.music.length)
			Conductor.songPosition = 0;

		lastPos = Conductor.songPosition;

		if (songControl || sectionControl)
			FlxG.sound.music.pause();
		else if (BindKey.getKey(TOGGLE_SONG, JUST_PRESSED))
		{
			vocals.time = FlxG.sound.music.time = Conductor.songPosition;

			if (FlxG.sound.music.playing)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}
			else
			{
				FlxG.sound.music.resume();
				vocals.resume();
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
			if (Math.abs(Conductor.songPosition - vocals.time) > 20)
				vocals.time = Conductor.songPosition;
		}

		if (noteSelector.visible)
		{
			noteSelector.attributes['sineAlpha'] += elapsed * noteSelector.attributes['sineSpeed'];
			noteSelector.alpha = FlxMath.remapToRange((1 - Math.sin(noteSelector.attributes['sineAlpha'] / Math.PI) * 0.5), 0, 1, 0.2, 0.6);
		}

		infoText.text = 'TIME: ${Tools.formatAccuracy(FlxMath.roundDecimal(Conductor.songPosition * 0.001, 2))} / ${(Tools.formatAccuracy(FlxMath.roundDecimal(FlxG.sound.music.length * 0.001, 2)))} [BEAT: ${curBeat}] [STEP: ${curStep}]';
		infoText.screenCenter(X);

		strum.y = Tools.lerpBound(strum.y,
			FlxMath.remapToRange(Conductor.songPosition, 0, FlxG.sound.music.length, strumLines[0].y, strumLines[0].y + strumLines[0].height), 35 * elapsed);

		super.update(elapsed);
	}

	private function mouseMovementCheck():Bool
	{
		if (FlxG.mouse.justMoved)
		{
			for (i in 0...strumLines.length)
			{
				var strum = strumLines[i];

				if (FlxG.mouse.overlaps(strum, mainCamera))
				{
					noteSelector.setGraphicSize(CELL_SIZE, CELL_SIZE);

					noteSelector.centerOffsets();
					noteSelector.updateHitbox();

					var cellPos:Float = 0;

					var k:Int = 0;
					for (j in 0...4)
					{
						if (FlxG.mouse.x > strum.attributes['box$j'])
							k = j;
					}

					cellPos = strum.attributes['box$k'];
					noteSelector.animation.play(noteAnimations[k]);

					noteSelector.setPosition(cellPos, Math.floor(FlxG.mouse.y / CELL_SIZE) * CELL_SIZE);

					noteSelector.attributes.set('noteDir', k);
					noteSelector.attributes.set('strumLine', i);
				}
			}
		}

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(strumLines[noteSelector.attributes.get('strumLine')], mainCamera))
			{
				if (FlxG.keys.pressed.CONTROL && FlxG.mouse.overlaps(renderedNotes))
				{
					renderedNotes.forEach(function(note:ChartNote)
					{
						if (note.isOnScreen() && FlxG.mouse.overlaps(note, mainCamera))
						{
							/*if (note.attachedNote != null)
								{
									Song.currentSong.sectionList
							}*/
							trace('removed a note, ${note.ID}');
						}
					});
				}
				else
				{
					var chartNote:ChartNote = new ChartNote(new Note(transformEitherPosition(noteSelector.y), noteSelector.attributes.get('noteDir'),
						noteSelector.attributes.get('strumLine'), 0, 0));

					var note:Note = chartNote.attachedNote;
					Song.currentSong.sectionList[Math.floor((note.strumTime / Conductor.stepCrochet) / 16)].notes.push({
						strumTime: note.strumTime,
						direction: note.direction,
						sustain: 0,
						mustPress: note.mustPress,
						noteAnim: singAnimations[note.direction],
						noteType: ""
					});

					chartNote.setGraphicSize(CELL_SIZE, CELL_SIZE);
					chartNote.updateHitbox();
					chartNote.x = strumLines[note.mustPress ? 1 : 0].x + (CELL_SIZE * note.direction);
					chartNote.y = FlxMath.remapToRange(note.strumTime, 0, FlxG.sound.music.length, strumLines[0].y, strumLines[0].y + strumLines[0].height);
					renderedNotes.add(chartNote);
				}
			}
		}

		return false;
	}

	private function songMovementCheck():Bool
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

	private function sectionMovementCheck():Bool
	{
		var pressedLeft:Bool = BindKey.getKey(SECTION_UP, JUST_PRESSED);
		var pressedRight:Bool = BindKey.getKey(SECTION_DOWN, JUST_PRESSED);

		if (pressedLeft || pressedRight)
		{
			var speed:Float = BindKey.getKey(MULTIPLY_BIND, PRESSED) ? -4 : -1;

			if (pressedRight)
				speed *= -1;

			Conductor.songPosition += Conductor.stepCrochet * 16 * speed;
		}

		return (pressedLeft || pressedRight);
	}

	private function transformEitherPosition(convertToY:Bool = false, value:Float):Float
	{
		if (convertToY)
			return FlxMath.remapToRange(value, 0, FlxG.sound.music.length, strumLines[0].y, strumLines[0].y + strumLines[0].height);

		return FlxMath.remapToRange(value, strumLines[0].y, strumLines[0].y + strumLines[0].height, 0, FlxG.sound.music.length);
	}

	override public function destroy()
	{
		Main.fps.alpha = 1.0;
		@:privateAccess
		for (outline in Main.fps.outlines)
			outline.alpha = 1.0;

		Note._noteFile = null;

		ChartNote.animationData = [];

		current = null;

		super.destroy();
	}
}

@:access(objects.notes.Note)
class ChartNote extends FlxSprite
{
	public static var animationData:Array<Animation> = [];

	public var attachedNote:Note;

	public override function new(note:Note)
	{
		super();

		this.attachedNote = note;

		active = false;

		frames = switch (Note._noteFile.atlasType)
		{
			case 'packer':
				Paths.getPackerAtlas('game/ui/noteSkins/${Song.metaData.noteSkin}/${Note.currentSkin}');
			default:
				Paths.getSparrowAtlas('game/ui/noteSkins/${Song.metaData.noteSkin}/${Note.currentSkin}');
		};

		playAnim();
	}

	private function playAnim():Void
	{
		for (animData in Note._noteFile.animationData)
		{
			if (animData.name == ChartEditorState.noteAnimations[attachedNote.direction])
			{
				animation.addByIndices(animData.name, animData.prefix, [0], "", animData.fps, animData.looped);
				animation.play(animData.name);
			}
		}
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

enum abstract MouseState(Int)
{
	var NORMAL:MouseState = 0;
	var DRAGGING:MouseState = 1;
	var IN_DRAG:MouseState = 2;
	var FROM_UI:MouseState = 3;
}