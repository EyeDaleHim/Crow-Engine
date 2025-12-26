package crow.states.internals;

import crow.objects.loading.LoadingScreen;
import crow.objects.soundtray.SoundTrayObject;
import crow.objects.transition.TransitionObject;

/**
 * The root state of the game.
 * This state typically holds global services (toasts, transitions, and soundtray) 
 * that persist throughout the game's lifecycle.
 * 
 * Data components generally should never touch this class.
 */
class RootState extends FlxState
{
	public var main(get, never):Class<Main>;

	function get_main():Class<Main>
	{
		return Main;
	}

	/**
	 * Get the current state the player is in.
	 * In debugging, this skips the chain of writing
	 * `FlxG.state.subState.subState. ...`.
	 */
	public var focusedState(get, never):MainState;

	public var rootCamera:FlxCamera;

	public var transitionObject:TransitionObject;
	public var soundTrayObject:SoundTrayObject;
	public var loadingScreenObject:LoadingScreen;

	public function new(?startState:() -> MainState)
	{
		super();

		rootCamera = new FlxCamera();
		rootCamera.bgColor = FlxColor.TRANSPARENT;

		var initialState:MainState;

		if (startState == null)
		{
			FlxG.log.warn("No start state provided to RootState.");
			initialState = new MainState();
		}
		else
		{
			initialState = startState();
		}

		transitionObject = new TransitionObject();
		transitionObject.camera = rootCamera;
		add(transitionObject);

		loadingScreenObject = new LoadingScreen();
		loadingScreenObject.camera = rootCamera;
		#if !USE_MULTITHREADING
		loadingScreenObject.forceInvisible();
		#end
		add(loadingScreenObject);

		soundTrayObject = new SoundTrayObject("sfx/soundtray/up", "sfx/soundtray/down", "sfx/soundtray/max");
		soundTrayObject.camera = rootCamera;
		add(soundTrayObject);

		persistentUpdate = true;

		updateRootCamera();

		openSubState(initialState);
	}

	override public function update(elapsed:Float)
	{
		updateSoundTray();

		super.update(elapsed);
	}

	public function updateSoundTray():Void
	{
		var updateSoundTray:Bool = false;
		var soundToPlay:FlxSound = null;
		if (Main.input.isTapped("volume_mute"))
		{
			FlxG.sound.muted = !FlxG.sound.muted;
			updateSoundTray = true;
		}
		else if (Main.input.isTapped("volume_up"))
		{
			FlxG.sound.volume = Math.min(1.0, FlxG.sound.volume + 0.1);
			soundToPlay = soundTrayObject.soundIncrease;
			updateSoundTray = true;
		}
		else if (Main.input.isTapped("volume_down"))
		{
			FlxG.sound.volume = Math.max(0.0, FlxG.sound.volume - 0.1);
			soundToPlay = soundTrayObject.soundDecrease;
			updateSoundTray = true;
		}

		if (updateSoundTray)
		{
			if (FlxG.sound.volume >= 1.0)
			{
				soundToPlay = soundTrayObject.soundMax;
			}

			if (soundToPlay != null)
			{
				soundToPlay.play(true);
			}

			soundTrayObject.show(true);
		}
	}

	public function updateRootCamera():Void
	{
		if (FlxG.cameras.list.contains(rootCamera))
		{
			FlxG.cameras.remove(rootCamera);
		}
		FlxG.cameras.add(rootCamera, false);
	}

	override function draw()
	{
		if (subState != null)
			subState.draw();

		@:privateAccess
		{
			final oldDefaultCameras = FlxCamera._defaultCameras;
			if (_cameras != null)
			{
				FlxCamera._defaultCameras = _cameras;
			}

			for (basic in members)
			{
				if (basic != null && basic.exists && basic.visible)
					basic.draw();
			}

			FlxCamera._defaultCameras = oldDefaultCameras;
		}
	}

	function get_focusedState():MainState
	{
		var _current:FlxState = this;
		while (_current.subState != null)
		{
			if (Std.isOfType(_current.subState, MainState))
			{
				_current = cast(_current.subState, MainState);
			}
		}

		return cast(_current, MainState);
	}
}
