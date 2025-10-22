package gear.input;

import openfl.display.Stage;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import flixel.input.keyboard.FlxKey; // For mapping key codes
import gear.assets.metadata.internals.InputMetadata;

class Input
{
	public static final inputPath:String = 'data/config/inputs.json';

	private var _actionBinds:Map<String, ActionBind>;
	private var _inputImpulses:Map<String, InputImpulse>; // Key: "device:code"
	private var _activeImpulses:Array<InputImpulse>; // List of impulses currently held down
	private var _justPressedImpulses:Array<InputImpulse>; // Impulses that became active THIS frame
	private var _justReleasedImpulses:Array<InputImpulse>; // Impulses that became inactive THIS frame

	/**
	 * Reads an internal input file.
	 * @param stage The OpenFL Stage to attach event listeners to. If null, FlxG.stage is used.
	 * @param inputFile The path to the input configuration JSON file.
	 */
	public function new(?stage:Stage, inputFile:String)
	{
		if (stage == null)
		{
			stage = FlxG.stage;
		}

		_actionBinds = new Map<String, ActionBind>();
		_inputImpulses = new Map<String, InputImpulse>();
		_activeImpulses = [];
		_justPressedImpulses = [];
		_justReleasedImpulses = [];

		if (stage != null)
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

			stage.addEventListener(MouseEvent.MOUSE_DOWN, (e) -> onMouseDown("LMB"));
			stage.addEventListener(MouseEvent.MOUSE_UP, (e) -> onMouseUp("LMB"));
			stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, (e) -> onMouseDown("MMB"));
			stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, (e) -> onMouseUp("MMB"));
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, (e) -> onMouseDown("RMB"));
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, (e) -> onMouseUp("RMB"));
		}
		else
		{
			trace("Error: Input system initialized without a valid Stage. Input events will not be captured.");
		}

		read(inputFile);
	}

	public function read(inputFile:String):Void
	{
		var rawContents = FlxG.assets.getTextUnsafe(inputFile);
		if (rawContents == null)
		{
			trace('Error: Input metadata file not found or empty: $inputFile');
			return;
		}

		try
		{
			var rawJson = Json.parse(JsonComment.removeComments(rawContents));
			var inputMetadata:InputMetadata = cast rawJson;

			for (actionBind in inputMetadata.binds)
			{
				_actionBinds.set(actionBind.id, actionBind);
			}
			trace('Input metadata loaded successfully from $inputFile.');
		}
		catch (e:Dynamic)
		{
			trace('Error parsing input metadata from $inputFile: $e');
		}
	}

	/**
	 * Call this method once per frame to update input states.
	 * @param elapsed The time elapsed since the last frame, in seconds.
	 */
	public function update(elapsed:Float):Void
	{
		// Clear just pressed/released states from previous frame
		_justPressedImpulses = [];
		_justReleasedImpulses = [];

		// Update duration for active impulses
		for (impulse in _inputImpulses)
		{
			if (impulse.active)
			{
				impulse.duration += elapsed;
			}
		}
	}

	// --- Event Handlers ---

	private function onKeyDown(e:KeyboardEvent):Void
	{
		var code = getKeyboardCode(e.keyCode);
		if (code == null)
			return; // Unknown or unmapped key

		final impulseKey = 'keyboard:$code';
		var impulse = _inputImpulses.get(impulseKey);
		if (impulse == null)
		{
			impulse = new InputImpulse("keyboard", code);
			_inputImpulses.set(impulseKey, impulse);
		}

		if (!impulse.active)
		{ // Only process if it was not active (i.e., just pressed)
			impulse.active = true;
			_justPressedImpulses.push(impulse);
			if (!_activeImpulses.contains(impulse))
			{
				_activeImpulses.push(impulse);
			}
		}
	}

	private function onKeyUp(e:KeyboardEvent):Void
	{
		var code = getKeyboardCode(e.keyCode);
		if (code == null)
			return;

		final impulseKey = 'keyboard:$code';
		var impulse = _inputImpulses.get(impulseKey);
		if (impulse == null)
			return; // Key was never tracked as pressed

		if (impulse.active)
		{ // Only process if it was active (i.e., just released)
			impulse.reset();
			_justReleasedImpulses.push(impulse);
			_activeImpulses.remove(impulse);
		}
	}

	private function onMouseDown(code:String):Void
	{
		if (code == null)
			return;

		final impulseKey = 'mouse:$code';
		var impulse = _inputImpulses.get(impulseKey);
		if (impulse == null)
		{
			impulse = new InputImpulse("mouse", code);
			_inputImpulses.set(impulseKey, impulse);
		}

		if (!impulse.active)
		{
			impulse.active = true;
			_justPressedImpulses.push(impulse);
			if (!_activeImpulses.contains(impulse))
			{
				_activeImpulses.push(impulse);
			}
		}
	}

	private function onMouseUp(code:String):Void
	{
		if (code == null)
			return;

		final impulseKey = 'mouse:$code';
		var impulse = _inputImpulses.get(impulseKey);
		if (impulse == null)
			return;

		if (impulse.active)
		{
			impulse.reset();
			_justReleasedImpulses.push(impulse);
			_activeImpulses.remove(impulse);
		}
	}

	// --- Public API for querying actions ---

	/**
	 * Checks if an action is currently active (held down).
	 * @param actionId The unique identifier of the action.
	 * @return True if the action is active, false otherwise.
	 */
	public function isPressed(actionId:String):Bool
	{
		var action = _actionBinds.get(actionId);
		if (action == null)
			return false;

		for (trigger in action.triggers)
		{
			if (isTriggerActive(trigger, false, false))
			{
				return true;
			}
		}
		return false;
	}

	/**
	 * Checks if an action was just activated (pressed this frame).
	 * @param actionId The unique identifier of the action.
	 * @return True if the action was just pressed, false otherwise.
	 */
	public function isJustPressed(actionId:String):Bool
	{
		var action = _actionBinds.get(actionId);
		if (action == null)
			return false;

		for (trigger in action.triggers)
		{
			if (isTriggerActive(trigger, true, false))
			{
				return true;
			}
		}
		return false;
	}

	/**
	 * Checks if an action was just deactivated (released this frame).
	 * @param actionId The unique identifier of the action.
	 * @return True if the action was just released, false otherwise.
	 */
	public function isJustReleased(actionId:String):Bool
	{
		var action = _actionBinds.get(actionId);
		if (action == null)
			return false;

		for (trigger in action.triggers)
		{
			if (isTriggerActive(trigger, false, true))
			{
				return true;
			}
		}
		return false;
	}

	/**
	 * Gets the duration (in seconds) that an action has been continuously active.
	 * For combo triggers, this returns the minimum duration of all inputs in the trigger.
	 * If multiple triggers are active, it returns the maximum of their minimum durations.
	 * @param actionId The unique identifier of the action.
	 * @return The duration in seconds, or 0 if the action is not active.
	 */
	public function getDuration(actionId:String):Float
	{
		var action = _actionBinds.get(actionId);
		if (action == null)
			return 0;

		var maxDuration:Float = 0;
		for (trigger in action.triggers)
		{
			if (isTriggerActive(trigger, false, false))
			{
				var currentTriggerMinDuration:Float = Math.POSITIVE_INFINITY;
				for (inputSource in trigger.inputs)
				{
					final impulse = _inputImpulses.get('${inputSource.device}:${inputSource.code}');
					if (impulse != null && impulse.active)
					{
						currentTriggerMinDuration = Math.min(currentTriggerMinDuration, impulse.duration);
					}
					else
					{
						// This case should ideally not be reached if isTriggerActive returned true,
						// but as a safeguard, if an input is unexpectedly not active, treat duration as 0.
						currentTriggerMinDuration = 0;
						break;
					}
				}
				if (currentTriggerMinDuration != Math.POSITIVE_INFINITY)
				{
					maxDuration = Math.max(maxDuration, currentTriggerMinDuration);
				}
			}
		}
		return maxDuration;
	}

	// --- Helper for checking trigger state ---

	private function isTriggerActive(trigger:InputTrigger, checkJustPressed:Bool, checkJustReleased:Bool):Bool
	{
		// 1. Handle exclusive logic
		if (trigger.exclusive != null && trigger.exclusive)
		{
			// If the number of currently active impulses does not exactly match the number of inputs
			// required by this exclusive trigger, then it cannot be active.
			if (_activeImpulses.length != trigger.inputs.length)
			{
				return false;
			}

			for (inputSource in trigger.inputs)
			{
				final impulse = _inputImpulses.get('${inputSource.device}:${inputSource.code}');
				if (impulse == null || !impulse.active)
				{
					return false;
				}
			}
			// If we reach here, all currently active impulses are exactly those specified in trigger.inputs.
			// The subsequent checks will verify their specific state (just pressed, just released, active).
		}

		// 2. Check individual inputs
		var allInputsMatch = true;

		for (i in 0...trigger.inputs.length)
		{
			var inputSource = trigger.inputs[i];
			final impulseKey = '${inputSource.device}:${inputSource.code}';
			var impulse = _inputImpulses.get(impulseKey);

			if (impulse == null)
			{
				allInputsMatch = false;
				break;
			}

			// Check based on requested state (pressed, just pressed, just released)
			var stateMatch = false;
			if (checkJustPressed)
				stateMatch = _justPressedImpulses.contains(impulse);
			else if (checkJustReleased)
				stateMatch = _justReleasedImpulses.contains(impulse);
			else // isPressed
				stateMatch = impulse.active;

			if (!stateMatch)
			{
				allInputsMatch = false;
				break;
			}
		}

		if (!allInputsMatch)
			return false;

		// 3. Handle orderSensitive logic
		if (trigger.orderSensitive != null && trigger.orderSensitive && trigger.inputs.length > 1)
		{
			if (checkJustPressed)
			{
				// For an order-sensitive combo to be "just pressed", the last key must have been just pressed.
				// All other keys in the combo must also be "just pressed" (duration == 0)
				// and their press order must be correct.
				var lastInput = trigger.inputs[trigger.inputs.length - 1];
				var lastImpulseKey = '${lastInput.device}:${lastInput.code}';
				var lastImpulse = _inputImpulses.get(lastImpulseKey);

				if (lastImpulse == null || !_justPressedImpulses.contains(lastImpulse))
					return false; // Last key wasn't just pressed.

				// Since all inputs must be "just pressed" for the combo to be "just pressed",
				// their durations should all be 0. The order check from the `isPressed` logic
				// still applies, but `impulse1.duration >= impulse2.duration` will be `0 >= 0`, which is true.
				for (inputSource in trigger.inputs)
				{
					if (_inputImpulses.get('${inputSource.device}:${inputSource.code}').duration > 0)
					{
						return false;
					}
				}
			}
			else if (checkJustReleased)
			{
				// Handle "just released" for order-sensitive combos based on the `comboRelease` condition.
				final releaseCondition = (trigger.comboRelease == "LAST") ? "LAST" : "ANY";

				if (releaseCondition == "LAST")
				{
					// "LAST": Only the last key in the sequence being released triggers the event,
					// while all other keys are still held.
					var lastInput = trigger.inputs[trigger.inputs.length - 1];
					var lastImpulse = _inputImpulses.get('${lastInput.device}:${lastInput.code}');

					if (lastImpulse == null || !_justReleasedImpulses.contains(lastImpulse))
					{
						return false; // The last key was not just released.
					}

					// Check that all other keys are still active (held).
					for (i in 0...trigger.inputs.length - 1)
					{
						var impulse = _inputImpulses.get('${trigger.inputs[i].device}:${trigger.inputs[i].code}');
						if (impulse == null || !impulse.active)
						{
							return false; // An earlier key in the sequence is not being held.
						}
					}
					// If we get here, the last key was just released and all others are held.
				}
				else // "ANY"
				{
					// "ANY": The combo is "just released" if it was fully active last frame,
					// and at least one key was released this frame.
					var justReleasedCount = 0;
					var activeCount = 0;
					for (inputSource in trigger.inputs)
					{
						var impulse = _inputImpulses.get('${inputSource.device}:${inputSource.code}');
						if (impulse != null)
						{
							if (_justReleasedImpulses.contains(impulse))
								justReleasedCount++;
							if (impulse.active)
								activeCount++;
						}
					}

					// The condition for "just released" is:
					// 1. At least one key was just released.
					// 2. The total number of keys that are *either* just-released or still-active
					//    must equal the total number of keys in the combo. This proves the combo
					//    was fully active in the previous frame.
					return justReleasedCount > 0 && (justReleasedCount + activeCount) == trigger.inputs.length;
				}
			}
			else // isPressed
			{
				// For an order-sensitive combo to be "pressed", all keys must be active,
				// and their press durations must be in descending order.
				for (i in 0...(trigger.inputs.length - 1))
				{
					var impulse1 = _inputImpulses.get('${trigger.inputs[i].device}:${trigger.inputs[i].code}');
					var impulse2 = _inputImpulses.get('${trigger.inputs[i + 1].device}:${trigger.inputs[i + 1].code}');
					if (impulse1.duration < impulse2.duration)
					{
						allInputsMatch = false;
						break;
					}
				}
			}
		}

		return allInputsMatch;
	}

	private function getKeyboardCode(keyCode:Int):String
	{
		var flxKey = FlxKey.toStringMap.get(keyCode);
		if (flxKey != null)
		{
			return flxKey;
		}

		trace('Warning: Unmapped keyboard key code: $keyCode');
		return null;
	}
}
