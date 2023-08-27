package objects.character;

@:allow(states.menus.StoryMenuState)
class WeekCharacter extends FlxSprite
{
	public var animOffsets:Map<String, FlxPoint> = [];
	public var idleList:Array<String> = [];
	public var confirmPose:String = ''; // leave blank to indicate no confirm pose

	public var char:String = '';

	private var _idleIndex:Int = 0;
	private var _posing:Bool = false;

	private var _animData:WeekCharacterFile;
	private var _failedChar:Bool = true;

	override function new(x:Float, y:Float, char:String = "bf")
	{
		super(x, y);

		this.char = char;

		var imagePath = Paths.imagePath('menus/storymenu/characters/data/$char');

		if (Assets.exists(imagePath.replace('png', 'json')))
		{
			_animData = Json.parse(Assets.getText(imagePath.replace('png', 'json')));
		}
		else
		{
			_failedChar = true;
			return;
		}

		frames = Paths.getSparrowAtlas('menus/storymenu/characters/$char');

		this.idleList = _animData.idleList;
		this.confirmPose = _animData.confirmPose;

		for (animData in _animData.animationList)
		{
			if (animData.indices != null && animData.indices.length > 0)
				animation.addByIndices(animData.name, animData.prefix, animData.indices, "", animData.fps, animData.looped);
			else
				animation.addByPrefix(animData.name, animData.prefix, animData.fps, animData.looped);

			if (animData.offset.x != 0 || animData.offset.y != 0)
				animOffsets.set(animData.name, FlxPoint.get(animData.offset.x, animData.offset.y));
		}

		flipX = _animData.flip.x;
		flipY = _animData.flip.y;

		scale.set(_animData.scale.x, _animData.scale.y);
		updateHitbox();

		dance();
		animation.finishCallback = function(name)
		{
			dance();
		}
	}

	public function dance():Void
	{
		if (idleList.length > 0)
		{
			_idleIndex++;
			_idleIndex = FlxMath.wrap(_idleIndex, 0, idleList.length - 1);

			animation.play(idleList[_idleIndex], true, false);
		}
	}
}

typedef WeekCharacterFile =
{
	var scale:{x:Float, y:Float};
	var flip:{x:Bool, y:Bool};
	var animationList:Array<Animation>;
	var idleList:Array<String>;
	var confirmPose:String;
	@:optional var atlasType:String;
}
