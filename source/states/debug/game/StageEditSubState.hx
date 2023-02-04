package states.debug.game;

// fuck yuo i have to make this temporary class so i dont have to edit the shit and re-compile every 7 minots
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import states.PlayState;
import utils.Tools;

class StageEditSubState extends MusicBeatSubState
{
	public static var isOpen:Bool = false;

	public var objectList:Array<String> = [
		'OPPONENT POSITIONS',
		'SPECTATOR POSITIONS',
		'PLAYER POSITIONS',
		'OPPONENT CAMERA POSITIONS',
		'SPECTATOR CAMERA POSITIONS',
		'PLAYER CAMERA POSITIONS'
	];

	public var curSelected:Int = 0;
	public var textList:FlxTypedGroup<FlxText>;

	override function create()
	{
		isOpen = true;

		textList = new FlxTypedGroup<FlxText>();
		add(textList);

		for (i in 0...objectList.length)
		{
			var textObject:FlxText = new FlxText(5, 30 + (15 * i), 0, objectList[i] + ': [0, 0]', 15);
			textObject.setFormat(Paths.font("vcr"), 15, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
			textObject.ID = i;
			textList.add(textObject);

			curSelected++;
			getValue();
		}

		curSelected = 0;

		textList.members[0].color = FlxColor.YELLOW;

		cameras = [PlayState.current.pauseCamera];

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.F6)
		{
			close();
			isOpen = false;
		}

		if (FlxG.keys.justPressed.UP)
			curSelected--;
		else if (FlxG.keys.justPressed.DOWN)
			curSelected++;
		else
		{
			curSelected = FlxMath.wrap(curSelected, 0, objectList.length - 1);
			for (object in textList.members)
			{
				object.color = (object.ID == curSelected ? FlxColor.YELLOW : FlxColor.WHITE);
			}

			getValue();
		}

		if (FlxG.keys.anyJustPressed([W, A, S, D]))
		{
			var keys:Array<Bool> = [
				FlxG.keys.justPressed.W,
				FlxG.keys.justPressed.A,
				FlxG.keys.justPressed.S,
				FlxG.keys.justPressed.D
			];
			var changeValue:Array<FlxPoint> = [new FlxPoint(0, -1), new FlxPoint(-1, 0), new FlxPoint(0, 1), new FlxPoint(1, 0)];

			var stageDataChar = PlayState.current.stageData.charPosList;
			var stageDataCam = PlayState.current.stageData.camPosList;

			for (key in keys)
			{
				if (key)
				{
					switch (curSelected)
					{
						case 0:
							stageDataChar.opponentPositions[0].x += changeValue[keys.indexOf(key)].x;
							stageDataChar.opponentPositions[0].y += changeValue[keys.indexOf(key)].y;
						case 1:
							stageDataChar.spectatorPositions[0].x += changeValue[keys.indexOf(key)].x;
							stageDataChar.spectatorPositions[0].y += changeValue[keys.indexOf(key)].y;
						case 2:
							stageDataChar.playerPositions[0].x += changeValue[keys.indexOf(key)].x;
							stageDataChar.playerPositions[0].y += changeValue[keys.indexOf(key)].y;
						case 3:
							stageDataCam.opponentPositions[0].x += changeValue[keys.indexOf(key)].x;
							stageDataCam.opponentPositions[0].y += changeValue[keys.indexOf(key)].y;
						case 4:
							stageDataCam.spectatorPositions[0].x += changeValue[keys.indexOf(key)].x;
							stageDataCam.spectatorPositions[0].y += changeValue[keys.indexOf(key)].y;
						case 5:
							stageDataCam.playerPositions[0].x += changeValue[keys.indexOf(key)].x;
							stageDataCam.playerPositions[0].y += changeValue[keys.indexOf(key)].y;
						default:
							new FlxPoint();
					}
				}
			}

			PlayState.current.opponent.setPosition(stageDataChar.opponentPositions[0].x, stageDataChar.opponentPositions[0].y);
			PlayState.current.spectator.setPosition(stageDataChar.spectatorPositions[0].x, stageDataChar.spectatorPositions[0].y);
			PlayState.current.player.setPosition(stageDataChar.playerPositions[0].x, stageDataChar.playerPositions[0].y);
		}
		getValue();

		super.update(elapsed);
	}

	private function getValue():FlxPoint
	{
		var selectedObject:FlxText = textList.members[curSelected];
		var selectedPoint:FlxPoint = switch (curSelected)
		{
			case 0:
				Tools.transformSimplePoint(new FlxPoint(), PlayState.current.stageData.charPosList.opponentPositions[0]);
			case 1:
				Tools.transformSimplePoint(new FlxPoint(), PlayState.current.stageData.charPosList.spectatorPositions[0]);
			case 2:
				Tools.transformSimplePoint(new FlxPoint(), PlayState.current.stageData.charPosList.playerPositions[0]);
			case 3:
				Tools.transformSimplePoint(new FlxPoint(), PlayState.current.stageData.camPosList.opponentPositions[0]);
			case 4:
				Tools.transformSimplePoint(new FlxPoint(), PlayState.current.stageData.camPosList.spectatorPositions[0]);
			case 5:
				Tools.transformSimplePoint(new FlxPoint(), PlayState.current.stageData.camPosList.playerPositions[0]);
			default:
				new FlxPoint();
		}

		if (selectedObject != null)
			selectedObject.text = objectList[curSelected] + ': [X: ${selectedPoint.x}, Y: ${selectedPoint.y}]';

		return selectedPoint;
	}
}
