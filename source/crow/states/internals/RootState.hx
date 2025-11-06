package crow.states.internals;

import crow.objects.soundtray.SoundTrayObject;
import crow.objects.transition.TransitionObject;

/**
 * The root state of the game.
 * This state typically holds global services (toasts, transitions, and soundtray) 
 * that persist throughout the game's lifecycle.
 * 
 * It is not necessary for data components to touch this class.
 */
class RootState extends FlxState
{
	public var main(get, never):Class<Main>;

	function get_main():Class<Main>
	{
		return Main;
	}

	public var rootCamera:FlxCamera;

	public var transitionObject:TransitionObject;
	public var soundTrayObject:SoundTrayObject;

	public function new(?startState:() -> MainState)
	{
		super();

		rootCamera = new FlxCamera();

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

		soundTrayObject = new SoundTrayObject();
		soundTrayObject.camera = rootCamera;
		add(soundTrayObject);

		persistentUpdate = true;

		updateRootCamera(FlxG.width, FlxG.height);

		openSubState(initialState);
	}

	public function updateRootCamera(?width:Int, ?height:Int):Void
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
}
