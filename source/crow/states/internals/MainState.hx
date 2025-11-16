package crow.states.internals;

import crow.ecs.entities.Camera;
import crow.assets.metadata.scenes.SceneMetadata.SceneCameras;
import crow.objects.transition.TransitionObject;
import flixel.util.typeLimit.NextState;

class MainState extends FlxSubState
{
	public var main(get, never):Class<Main>;

	function get_main():Class<Main>
	{
		return Main;
	}

	public var transitionObject:TransitionObject;
	public var cameraList:Array<Camera>;

	public function new()
	{
		super();

		bgColor = 0xFF000000;
		destroySubStates = false;

		persistentUpdate = persistentDraw = false;
	}

	public function createCamerasFromData(data:SceneCameras):Void
	{
		if (data?.length == 0)
		{
			data = [{name: "_main"}];
		}

		for (camera in data)
		{

		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (transitionObject != null && transitionObject.exists && transitionObject.alive && transitionObject.active)
		{
			transitionObject.update(elapsed);
		}
	}

	override public function draw()
	{
		super.draw();

		if (transitionObject != null && transitionObject.exists && transitionObject.alive && transitionObject.exists)
		{
			transitionObject.draw();
		}
	}

	public function transitionIn(?callback:() -> Void):Void
	{
		checkTransition();
		transitionObject.startIn(callback);
	}

	public function transitionOut(?callback:() -> Void):Void
	{
		checkTransition();
		transitionObject.startOut(callback);
	}

	public function next(nextState:NextState, ?transitions:Bool = true, ?transferAttributes:Bool = true)
	{
		if (nextState != null)
		{
			var state = nextState.createInstance();
			if (Std.isOfType(state, MainState))
			{
				var castedState = cast(state, MainState);
				if (transferAttributes)
				{
					transferAttributeHelper(castedState);
				}
				transitionOut(() ->
				{
					openSubState(castedState);
				});
			}
		}
	}

	/**
	 * Helper function to transfer common attributes to the next state.
	 * This can be overridden by subclasses to transfer additional state.
	 */
	public function transferAttributeHelper(state:MainState):Void
	{
		state.transitionObject = transitionObject;
	}

	private function checkTransition():Void
	{
		if (transitionObject == null)
		{
			transitionObject = new TransitionObject();
		}
	}
}
