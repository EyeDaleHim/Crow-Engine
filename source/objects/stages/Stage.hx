package objects.stages;

class Stage extends FlxTypedGroup<FlxObject>
{
	public static final PLAYER_NAME:String = "player";
	public static final SPECTATOR_NAME:String = "spectator";
	public static final OPPONENT_NAME:String = "opponent";

	public var name:String = "";
	public var uiSkin(default, null):String = "";
	public var defaultZoom:Float = 0.9;
	public var cameraSpeed:Float = 1.0;

	public var positionPoints(default, null):Map<String, FlxPoint> = [];
	public var cameraPoints(default, null):Map<String, FlxPoint> = [];

	// references to positions in the members array
	public var _playerObject:FlxObject;
	public var _spectatorObject:FlxObject;
	public var _opponentObject:FlxObject;

	public function new()
	{
		super();

		_playerObject = new FlxObject();
		_spectatorObject = new FlxObject();
		_opponentObject = new FlxObject();
	}

	public function initializeStage(characters:Array<Array<Character>>):Void
	{
		var _setCharacters:Bool = false;

		if (characters?.length > 0)
		{
			_setCharacters = true;

			var objectOrder:Array<FlxObject> = [_spectatorObject, _opponentObject, _playerObject];
			var renderOrder:Array<String> = [SPECTATOR_NAME, OPPONENT_NAME, PLAYER_NAME];

			for (i in 0...characters.length)
			{
				var startIndex:Int = members.indexOf(objectOrder[i]);

				if (characters[i]?.length != 0)
				{
					objectOrder[i].setSize(characters[i][0].width, characters[i][0].height);

					for (j in 0...characters[i].length)
					{
						if (!members.contains(objectOrder[i]))
						{
							add(characters[i][j]);
						}
						else
						{
							if (j == 0)
								replace(objectOrder[i], characters[i][j]);
							else
								insert(startIndex + 1, characters[i][j]);
						}

						var newPosition:FlxPoint = getCharPos(renderOrder[i]);
						characters[i][j].setPosition(newPosition.x, newPosition.y);
					}
				}
			}
		}

		if (!cameraPoints.exists(PLAYER_NAME))
			setPlayerCamPos(getPlayerCamPos());
		if (!cameraPoints.exists(OPPONENT_NAME))
			setOpponentCamPos(getOpponentCamPos().add(_opponentObject.width, _opponentObject.height / 2));
		if (!cameraPoints.exists(SPECTATOR_NAME))
			setSpectatorCamPos(getSpectatorCamPos());

		FlxDestroyUtil.destroy(_playerObject);
		FlxDestroyUtil.destroy(_spectatorObject);
		FlxDestroyUtil.destroy(_opponentObject);
	}

	public function beatHit(beat:Int):Void
	{
	}

	public function stepHit(step:Int):Void
	{
	}

	public function sectionHit(section:Int):Void
	{
	}

	public function getCharPos(name:String):FlxPoint
	{
		return positionPoints.exists(name) ? positionPoints.get(name) : FlxPoint.get();
	}

	public function getCameraPos(name:String):FlxPoint
	{
		return cameraPoints.exists(name) ? cameraPoints.get(name) : getCharPos(name);
	}

	public function getPlayerPos():FlxPoint
	{
		return positionPoints.exists(PLAYER_NAME) ? positionPoints.get(PLAYER_NAME) : FlxPoint.get(770, 100);
	}

	public function getSpectatorPos():FlxPoint
	{
		return positionPoints.exists(SPECTATOR_NAME) ? positionPoints.get(SPECTATOR_NAME) : FlxPoint.get(400, 130);
	}

	public function getOpponentPos():FlxPoint
	{
		return positionPoints.exists(OPPONENT_NAME) ? positionPoints.get(OPPONENT_NAME) : FlxPoint.get(100, 100);
	}

	public function getPlayerCamPos():FlxPoint
	{
		return cameraPoints.exists(PLAYER_NAME) ? cameraPoints.get(PLAYER_NAME) : getPlayerPos() + FlxPoint.get(-100, -50);
	}

	public function getSpectatorCamPos():FlxPoint
	{
		return cameraPoints.exists(SPECTATOR_NAME) ? cameraPoints.get(SPECTATOR_NAME) : getSpectatorPos() + FlxPoint.get(150, 30);
	}

	public function getOpponentCamPos():FlxPoint
	{
		return cameraPoints.exists(OPPONENT_NAME) ? cameraPoints.get(OPPONENT_NAME) : getOpponentPos() + FlxPoint.get(100, -100);
	}

	public function setCharPos(name:String, ?x:Float = 0.0, ?y:Float = 0.0, ?newPoint:FlxPoint):FlxPoint
	{
		if (positionPoints.exists(name))
		{
			if (newPoint != null)
				positionPoints.get(name).copyFrom(newPoint);
			else
				positionPoints.get(name).set(x, y);
		}
		else
		{
			positionPoints.set(name, newPoint ?? FlxPoint.get(x, y));
		}

		return positionPoints.get(name);
	}

	inline public function setPlayerPos(?x:Float = 0.0, ?y:Float = 0.0, ?newPoint:FlxPoint):FlxPoint
	{
		return setCharPos(PLAYER_NAME, x, y, newPoint);
	}

	inline public function setSpectatorPos(?x:Float = 0.0, ?y:Float = 0.0, ?newPoint:FlxPoint):FlxPoint
	{
		return setCharPos(SPECTATOR_NAME, x, y, newPoint);
	}

	inline public function setOpponentPos(?x:Float = 0.0, ?y:Float = 0.0, ?newPoint:FlxPoint):FlxPoint
	{
		return setCharPos(OPPONENT_NAME, x, y, newPoint);
	}

	public function setCamPos(name:String, ?x:Float = 0.0, ?y:Float = 0.0, ?newPoint:FlxPoint):FlxPoint
	{
		if (cameraPoints.exists(name))
		{
			if (newPoint != null)
				cameraPoints.get(name).copyFrom(newPoint);
			else
				cameraPoints.get(name).set(x, y);
		}
		else
		{
			cameraPoints.set(name, newPoint ?? FlxPoint.get(x, y));
		}

		return cameraPoints.get(name);
	}

	inline public function setPlayerCamPos(?x:Float = 0.0, ?y:Float = 0.0, ?newPoint:FlxPoint):FlxPoint
	{
		return setCamPos(PLAYER_NAME, x, y, newPoint);
	}

	inline public function setSpectatorCamPos(?x:Float = 0.0, ?y:Float = 0.0, ?newPoint:FlxPoint):FlxPoint
	{
		return setCamPos(SPECTATOR_NAME, x, y, newPoint);
	}

	inline public function setOpponentCamPos(?x:Float = 0.0, ?y:Float = 0.0, ?newPoint:FlxPoint):FlxPoint
	{
		return setCamPos(OPPONENT_NAME, x, y, newPoint);
	}
}
