package crow.states.internals;

import crow.assets.metadata.scenes.SceneMetadata.SceneContexts;
import crow.assets.metadata.scenes.SceneMetadata.SceneCameras;
import crow.assets.metadata.levels.GameStemData;
import crow.ecs.entities.Camera;
import crow.objects.transition.TransitionObject;
import flixel.util.typeLimit.NextState;

class MainState extends FlxSubState
{
	public var main(get, never):Class<Main>;

	function get_main():Class<Main>
	{
		return Main;
	}

	public var parentState(get, never):RootState;

	function get_parentState():RootState
	{
		if (Std.isOfType(FlxG.state, RootState))
		{
			return cast(FlxG.state, RootState);
		}

		return null;
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

		for (camera in data) {}
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

	public function handleContexts(contexts:SceneContexts, ?async:Bool = false, ?asyncCall:() -> Void = null)
	{
		if (contexts != null)
		{
			if (contexts.unload != null)
			{
				for (contextName in contexts.unload)
				{
					Main.assets.unloadContext(contextName);
				}
			}
			if (contexts.load != null)
			{
				if (async)
				{
					if (parentState != null)
					{
						parentState.loadingScreenObject.fadeIn();
					}
					Main.assets.loadContextsAsync(contexts.load).progress((progress, length) ->
					{
						haxe.MainLoop.runInMainThread(() ->
						{
							if (parentState != null)
							{
								parentState.loadingScreenObject.setProgress((progress / length) * 100);
							}
						});
					}).complete(() ->
						{
							if (parentState != null && asyncCall != null)
							{
								// Next thread!
								// I disabled entity builder thread for now
								parentState.loadingScreenObject.fadeOut(() ->
								{
									haxe.MainLoop.runInMainThread(asyncCall);
								});
								// haxe.MainLoop.runInMainThread(asyncCall);
							}

							Main.assetAsyncThread.clearSignals();
						});
				}
				else
				{
					for (contextName in contexts.load)
					{
						Main.assets.loadContext(contextName);
					}
				}
			}
		}

		if (asyncCall != null)
		{
			asyncCall();
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

	public function loadGame(gameStem:GameStemData):Void
	{
		if (gameStem.level == null && gameStem.playlist?.length == 0)
		{
			trace("ERROR: No level or playlist provided to loadGame.");
			return;
		}

		if (Main.gameSession == null)
			Main.gameSession = new PlayState();
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
