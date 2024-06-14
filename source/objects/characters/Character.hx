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

	override public function update(elapsed:Float)
	{
		if (singTimer > 0.0)
			singTimer -= elapsed;

		super.update(elapsed);
	}

	override public function beatHit()
	{
		// pre super.beatHit();

		var lastIndex:Int = bopIndex;

		if (beatBop > 0 && bopList.length > 0)
		{
			bopIndex++;
			bopIndex %= bopList.length;
		}

		if (singTimer <= 0 && bopList[bopIndex]?.length > 0)
			playAnimation(bopList[bopIndex], lastIndex == bopIndex);

		super.beatHit();
	}
}
