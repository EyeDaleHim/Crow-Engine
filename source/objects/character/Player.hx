package objects.character;

using StringTools;

class Player extends objects.character.Character
{
	public var stunnedTimer:Float = 0.0;

	override function update(elapsed:Float)
	{
		if (animation.curAnim != null)
		{
			if (singList.contains(animation.curAnim.name))
			{
				_animationTimer += elapsed;
			}
			else
				_animationTimer = 0;

			if (missList.contains(animation.curAnim.name))
			{
				if (_animationTimer >= 0.35)
					playAnim(idleList[_idleIndex], true, false, 10);
			}
		}

		if (stunnedTimer >= 0.0)
			stunnedTimer -= elapsed;
		else
			stunnedTimer = 0.0;

		super.update(elapsed);
	}
}
