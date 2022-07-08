package;

import flixel.FlxSprite;

using StringTools;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public var char:String;
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		changeIcon(char);
		antialiasing = true;
		scrollFactor.set();
	}

	public function swapOldIcon()
	{
		isOldIcon = !isOldIcon;
		
		if (isOldIcon)
		{
			changeIcon('bf-old');
		}
		else
		{
			changeIcon('bf');
		}
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String)
	{
		if (char != 'bf-pixel' && char != 'bf-old')
			char = char.split('-')[0].trim();

		if (char != this.char)
		{
			if (animation.getByName(char) == null)
			{
				loadGraphic(Paths.image('icons/icon-' + char), true, 150, 150);
				animation.add(char, [0, 1], 0, false, isPlayer);
			}

			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (width - 150) / 2;
			updateHitbox();
			animation.play(char);
			this.char = char;
		}
	}

	override public function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
