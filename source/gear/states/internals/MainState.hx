package gear.states.internals;

import gear.objects.ui.TransitionObject;
import flixel.util.typeLimit.NextState;

class MainState extends FlxSubState
{
	public var main(get, never):Class<Main>;

	function get_main():Class<Main>
	{
		return Main;
	}

	public var transitionObject:TransitionObject;

	public function new()
	{
		super();

		if (transitionObject != null)
		{
			transitionObject.startIn();
		}

		bgColor = 0xFF000000;
		destroySubStates = false;
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
