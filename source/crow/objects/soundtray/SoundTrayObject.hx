package crow.objects.soundtray;

import flixel.system.FlxAssets;
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
	public var text:FlxText;

	/**
	 * The function to get the current volume of the sound tray.
	 */
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

	/**
	 * How long to show the sound tray.
	 */
	public var showDuration:Float = 1.0;

	private var _showTween:FlxTween;
	private var _showTimer:FlxTimer;

	private var _hideTween:FlxTween;

	private var _textWrapper:AbsolutePositionSprite; // the wrapper for the text, we can't add normal flxtext here

	public function new(?soundIncrease:String, ?soundDecrease:String, ?soundMax:String)
	{
		super();

		final defaultSound:FlxSoundAsset = FlxAssets.getSoundAddExtension("flixel/sounds/beep");

		this.soundIncrease = FlxG.sound.load(soundIncrease != null ? soundIncrease : defaultSound);
		this.soundDecrease = FlxG.sound.load(soundDecrease != null ? soundDecrease : defaultSound);
		this.soundMax = FlxG.sound.load(soundMax != null ? soundMax : defaultSound);

		background = new AbsolutePositionSprite();
		background.makeGraphic(150, 50, FlxColor.WHITE);
		background.color = FlxColor.BLACK;
		background.alpha = 0.6;
		add(background);

		backBar = new AbsolutePositionSprite(10, 4);
		backBar.makeGraphic(130, 15, FlxColor.WHITE.getDarkened(0.5));
		add(backBar);

		frontBar = new AbsolutePositionSprite(10, 4);
		frontBar.makeGraphic(130, 15, FlxColor.WHITE);
		frontBar.origin.x = 0.0;
		add(frontBar);

		header = new AbsolutePositionSprite();
		header.makeGraphic(10, 17);
		header.setPosition(frontBar.x + frontBar.width - header.width, frontBar.y - 1);
		add(header);

		text = new FlxText(0, height, width, "100%", 20);
		text.y -= text.height;
		text.font = "vcr";
		text.setBorderStyle(OUTLINE, FlxColor.BLACK, 2, 1);
		text.alignment = CENTER;
		@:privateAccess
		text.regenGraphic();

		_textWrapper = new AbsolutePositionSprite(text);
		add(_textWrapper);

		this.y = 4.0;
		cameraCenter(X);

		hide(true);
	}

	public function show(?updateBar:Bool)
	{
		// Min to max assumes 0 to 1
		if (updateBar)
		{
			final ratio = getVolume() ?? 1.0;
			frontBar.scale.x = ratio;

			header.x = frontBar.x + (frontBar.width * ratio) - header.width;

			if (FlxG.sound.muted)
				text.text = '-MUTED-';
			else
				text.text = '${Math.floor(ratio * 100)}%';
		}

		final consecutive:Bool = _showTimer != null;

		revive();
		resetInternals();

		if (!consecutive)
		{
			y = 4.0;
			alpha = 0.0;

			_showTween = FlxTween.tween(this, {alpha: 1.0}, (1 / 60) * 4);
		}
		else
		{
			alpha = 1.0;
		}

		_showTimer = FlxTimer.wait(showDuration, hide.bind(false));
	}

	public function hide(?instant:Bool = false)
	{
		resetInternals();

		if (instant)
		{
			kill();
			return;
		}

		_hideTween = FlxTween.tween(this, {y: -height - 10}, 0.75, {
			ease: FlxEase.expoOut,
			onComplete: (_) ->
			{
				kill();
			}
		});
	}

	private inline function resetInternals():Void
	{
		if (_showTween != null)
		{
			_showTween.cancel();
			_showTween = null;
		}

		if (_hideTween != null)
		{
			_hideTween.cancel();
			_hideTween = null;
		}

		if (_showTimer != null)
		{
			_showTimer.cancel();
			_showTimer = null;
		}
	}
}
