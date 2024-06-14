package objects.characters;

class Character extends Bopper
{
	public var singTimer:Float = 0.0;

	public var missList:Array<String> = [];
	public var singList:Array<String> = [];

	public var data:CharacterData;

	public function new(?x:Float = 0.0, ?y:Float = 0.0, name:String)
	{
		var path:String = Assets.assetPath('images/characters/$name/$name.json');
		if (Assets.exists(path))
			data = Json.parse(Assets.readText(path));
		data = ValidateUtils.validateCharData(data);

		super(x, y, name);

		frames = Assets.frames('characters/$name/$name');

		if (data.animations.length > 0)
		{
			for (anim in data.animations)
			{
				anim = ValidateUtils.validateAnimData(anim);

				if (anim.indices.length > 0)
					animation.addByIndices(anim.name, anim.prefix, anim.indices, "", anim.fps, anim.looped);
				else
					animation.addByPrefix(anim.name, anim.prefix, anim.fps, anim.looped);

				animOffsets.set(anim.name, FlxPoint.get(anim.offset.x, anim.offset.y));
			}
		}

		bopList = data.bopList;
		singList = data.singList;
		missList = data.missList;

		if (bopList.length > 0)
		{
			playAnimation(bopList[0]);
			animation.finish();
		}
	}

	public var updateCallback:FlxTypedSignal<Void->Void> = new FlxTypedSignal<Void->Void>();

	override public function update(elapsed:Float)
	{
		updateCallback.dispatch();

		if (singTimer > 0.0)
			singTimer -= elapsed;

		super.update(elapsed);
	}

	override public function beatHit()
	{
		// pre super.beatHit();

		if (singTimer <= 0.0)
		{
			var lastIndex:Int = bopIndex;

			if (beatBop > 0 && bopList.length > 0)
			{
				bopIndex++;
				bopIndex %= bopList.length;
			}

			if (bopList[bopIndex]?.length > 0)
				playAnimation(bopList[bopIndex], lastIndex == bopIndex);
		}

		// super.beatHit();
	}
}
