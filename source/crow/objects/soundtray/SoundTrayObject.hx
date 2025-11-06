package crow.objects.soundtray;

import flixel.system.FlxAssets;
import crow.objects.dependencies.AbsolutePositionText;
import crow.objects.dependencies.AbsolutePositionSprite;
import crow.objects.dependencies.AbsolutePositionSpriteList;

class SoundTrayObject extends AbsolutePositionSpriteList
{
	/**
	 * The background sprite for the sound tray.
	 */
	public var background:AbsolutePositionSprite;

	/**
	 * The bar sprite for the sound tray.
	 * 
	 * Tracks the current volume.
	 */
	public var frontBar:AbsolutePositionSprite;

	/**
	 * The back bar sprite for the sound tray.
	 * 
	 * Stays at the maximum volume.
	 */
	public var backBar:AbsolutePositionSprite;

	/**
	 * The header sprite for the sound tray.
	 */
	public var header:AbsolutePositionSprite;

	/**
	 * The text object for the sound tray.
	 */
	public var text:AbsolutePositionText;

	public var getVolume:() -> Float = () ->
	{
		if (FlxG.sound.muted)
		{
			return 0.0;
		}

		return FlxG.sound.volume;
	};

	/**
	 * The sound to play when the volume is increased.
	 */
	public var soundIncrease:FlxSound;

	/**
	 * The sound to play when the volume is decreased.
	 */
	public var soundDecrease:FlxSound;

	/**
	 * The sound to play when the volume reaches its maximum.
	 */
	public var soundMax:FlxSound;

	public function new(?soundIncrease:String, ?soundDecrease:String, ?soundMax:String)
	{
		super();

		final defaultSound:FlxSoundAsset = FlxAssets.getSoundAddExtension("flixel/sounds/beep");

		this.soundIncrease = FlxG.sound.load(soundIncrease != null ? soundIncrease : defaultSound);
		this.soundDecrease = FlxG.sound.load(soundDecrease != null ? soundDecrease : defaultSound);
		this.soundMax = FlxG.sound.load(soundMax != null ? soundMax : defaultSound);

		background = new AbsolutePositionSprite();
		background.makeGraphic(150, 50, FlxColor.WHITE);
		background.alpha = 0.1;
		add(background);

		backBar = new AbsolutePositionSprite(10, 4);
		backBar.makeGraphic(130, 15, FlxColor.WHITE.getDarkened(0.5));
		add(backBar);

		frontBar = new AbsolutePositionSprite(10, 4);
		frontBar.makeGraphic(130, 15, FlxColor.WHITE);
		add(frontBar);

		header = new AbsolutePositionSprite();
		header.makeGraphic(10, 17);
		header.setPosition(frontBar.x + frontBar.width - header.width, frontBar.y - 1);
		add(header);

		this.y = 4.0;
		cameraCenter(X);
	}

	public function show(?updateBar:Bool)
	{
		// Min to max assumes 0 to 1
		if (updateBar)
		{
			final ratio = getVolume() ?? 1.0;
			frontBar.scale.x = ratio;
			frontBar.updateHitbox();
			frontBar.x = 10;

			header.x = frontBar.x + frontBar.width - header.width;
		}
	}
}
