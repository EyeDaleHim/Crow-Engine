package crow.objects.loading;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * A sprite group that represents the loading screen.
 * It creates its own camera to be independent of the main game camera.
 */
class LoadingScreen extends FlxSpriteGroup
{
	/**
	 * The minimum time the loading screen should be displayed.
	 */
	public static final MIN_TIME:Float = 2.0;

	/**
	 * The loading screen background.
	 */
	public var background:FlxSprite;

	/**
	 * The logo for the loading screen.
	 */
	public var logo:FlxSprite;

	/**
	 * The progress bar for the loading screen.
	 */
	public var progressBar:FlxSprite;

	private var _targetProgress:Float = 0.0;
	private var _currentProgress:Float = 0.0;
	private var _startTime:Int = 0;

	public function new()
	{
		super();

		background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		background.active = false;
		#if debug
		background.alpha = 0.5;
		#end
		add(background);

		logo = new FlxSprite().loadGraphic("generic/crow_engine_logo");
		logo.x = FlxG.width - logo.width - 60;
		logo.y = FlxG.height - logo.height - 40;
		logo.active = false;
		add(logo);

		progressBar = new FlxSprite(0, FlxG.height - 20).makeGraphic(FlxG.width, 20, FlxColor.WHITE);
		progressBar.origin.x = 0.0;
		progressBar.active = false;
		add(progressBar);
	}

	/**
	 * Readies the loading screen for use.
	 * 
	 * This resets a few fields back to their defaults.
	 */
	public function ready():Void
	{
		_targetProgress = 0.0;
		_currentProgress = 0.0;
		progressBar.scale.x = 0;
	}

	public function fadeIn(?onComplete:() -> Void):Void
	{
		_startTime = FlxG.game.ticks;
		alpha = 0.0;
		FlxTween.tween(this, {alpha: 1.0}, 1.0, {
			#if debug
			onUpdate: (_) ->
			{
				background.alpha = alpha * 0.5;
			},
			#end
			onComplete: (_) ->
			{
				if (onComplete != null)
				{
					onComplete();
				}
			}
		});
	}

	public function fadeOut(?onComplete:() -> Void):Void
	{
		var timeOpen = (FlxG.game.ticks - _startTime) / 1000;
		var delay = 0.0;

		if (timeOpen < MIN_TIME)
		{
			delay = MIN_TIME - timeOpen;
		}

		alpha = 1.0;
		FlxTween.tween(this, {alpha: 0.0}, 1.0, {
			startDelay: Math.max(delay, 0.0),
			onComplete: (_) ->
			{
				if (onComplete != null)
				{
					onComplete();
				}
			}
		});
	}

	/**
	 * Updates the progress bar.
	 * @param percent The progress percentage from 0 to 1.
	 */
	public function setProgress(percent:Float):Void
	{
		_targetProgress = percent;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		_currentProgress = FlxMath.lerp(_currentProgress, _targetProgress, elapsed * 5.0);
		if (Math.abs(_targetProgress - _currentProgress) < 0.1)
			_currentProgress = _targetProgress;

		progressBar.scale.x = _currentProgress / 100;
	}

	override function destroy():Void
	{
		FlxG.cameras.remove(camera);
		camera = null;
		super.destroy();
	}
}