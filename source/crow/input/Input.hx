package crow.input;

import openfl.display.Stage;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import lime.system.System;
import flixel.input.keyboard.FlxKey; // For mapping key codes
import crow.assets.metadata.internals.InputMetadata;
import crow.input.ComboReleaseCondition;
import crow.input.InputDevice;
import crow.ds.Set;
import crow.input.MouseButton;

class Input
{
	public static final inputPath:String = 'data/config/inputs';

	private var _actionBinds:Map<String, ActionBind>;
	private var _inputImpulses:Map<Int, InputImpulse>; // Key: (device << 24) | code
	private var _activeImpulses:Set<InputImpulse>; // Set of impulses currently held down
	private var _justPressedImpulses:Set<InputImpulse>; // Impulses that became active THIS frame
	private var _justReleasedImpulses:Set<InputImpulse>; // Impulses that became inactive THIS frame

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
		_inputImpulses = new Map<Int, InputImpulse>();
		_activeImpulses = new Set();
		_justPressedImpulses = new Set();
		_justReleasedImpulses = new Set();

		if (stage != null)
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

			stage.addEventListener(MouseEvent.MOUSE_DOWN, (e) -> onMouseDown(MouseButton.Left));
			stage.addEventListener(MouseEvent.MOUSE_UP, (e) -> onMouseUp(MouseButton.Left));
			stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, (e) -> onMouseDown(MouseButton.Middle));
			stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, (e) -> onMouseUp(MouseButton.Middle));
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, (e) -> onMouseDown(MouseButton.Right));
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, (e) -> onMouseUp(MouseButton.Right));
		}
		else
		{
			trace("Error: Input system initialized without a valid Stage. Input events will not be captured.");
		}

		read(inputFile);
	}

	public function read(inputFile:String):Void
	{
		try
		{
			var inputMetadata:InputMetadata = cast Main.assets.json(inputFile);
			if (inputMetadata == null)
			{
				trace('Error: Input metadata file not found or empty: $inputFile');
			}

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
		// Update duration for active impulses
		for (impulse in _activeImpulses)
		{
			if (impulse.active)
			{
				impulse.duration += elapsed;
			}
		}
	}

	/**
	 * Call this method after the main game update to clear frame-specific input states.
	 * 
	 * Typically this indicates the game is done processing inputs for that frame.
	 */
	public function postUpdate():Void
	{
		// Reset impulses that were released this frame.
		for (impulse in _justReleasedImpulses)
		{
			impulse.reset();
		}
		// Clear just pressed/released states from this frame, preparing for the next.
		_justPressedImpulses.clear();
		_justReleasedImpulses.clear();
	}

	// --- Event Handlers ---

	private function onKeyDown(e:KeyboardEvent):Void
	{
		final timestamp = System.getTimer();
		var code = getKeyboardCode(e.keyCode);
		if (code == null)
			return; // Unknown or unmapped key

		final impulseKey = _getImpulseKey(InputDevice.Keyboard, e.keyCode);
		var impulse = _inputImpulses.get(impulseKey);
		if (impulse == null)
		{
			impulse = new InputImpulse(impulseKey);
			_inputImpulses.set(impulseKey, impulse);
		}

		if (!impulse.active)
		{ // Only process if it was not active (i.e., just pressed)
			impulse.active = true;
			impulse.timestamp = timestamp;
			_justPressedImpulses.add(impulse);
			_activeImpulses.add(impulse);
		}
	}

	private function onKeyUp(e:KeyboardEvent):Void
	{
		var code = getKeyboardCode(e.keyCode);
		if (code == null)
			return;

		final impulseKey = _getImpulseKey(InputDevice.Keyboard, e.keyCode);
		var impulse = _inputImpulses.get(impulseKey);
		if (impulse == null)
			return; // Key was never tracked as pressed

		if (impulse.active)
		{ // Only process if it was active (i.e., just released)
			impulse.active = false;
			_justReleasedImpulses.add(impulse);
			_activeImpulses.remove(impulse);
		}
	}

	private function onMouseDown(code:MouseButton):Void
	{
		final timestamp = System.getTimer();
		if (code == null)
			return;

		final buttonId = MouseButton.toId(code);
		if (buttonId == -1) return;

		final impulseKey = _getImpulseKey(InputDevice.Mouse, buttonId);
		var impulse = _inputImpulses.get(impulseKey);
		if (impulse == null)
		{
			impulse = new InputImpulse(impulseKey);
			_inputImpulses.set(impulseKey, impulse);
		}

		if (!impulse.active)
		{
			impulse.active = true;
			impulse.timestamp = timestamp;
			_justPressedImpulses.add(impulse);
			_activeImpulses.add(impulse);
		}
	}

	private function onMouseUp(code:MouseButton):Void
	{
		if (code == null)
			return;

		final buttonId = MouseButton.toId(code);
		if (buttonId == -1) return;

		final impulseKey = _getImpulseKey(InputDevice.Mouse, buttonId);
		var impulse = _inputImpulses.get(impulseKey);
		if (impulse == null)
			return;

		if (impulse.active)
		{
			impulse.active = false;
			_justReleasedImpulses.add(impulse);
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
	 * Checks if an action was just released, and was held for a duration within the specified range.
	 * @param actionId The unique identifier of the action.
	 * @param minDuration The minimum duration (inclusive) the action must have been held, in seconds.
	 * @param maxDuration The maximum duration (inclusive) the action must have been held, in seconds.
	 * @return True if the action was just released within the duration constraints, false otherwise.
	 */
	public function isJustReleasedWithDuration(actionId:String, minDuration:Float, maxDuration:Float):Bool
	{
		var action = _actionBinds.get(actionId);
		if (action == null)
			return false;

		for (trigger in action.triggers)
		{
			if (isTriggerActiveWithDuration(trigger, minDuration, maxDuration))
			{
				return true;
			}
		}
		return false;
	}

	/**
	 * Checks if an action was just "tapped" (released after being held for a short time).
	 * This is a convenience function for `isJustReleasedWithDuration(actionId, 0, maxDuration)`.
	 * @param actionId The unique identifier of the action.
	 * @param maxDuration The maximum duration the action could be held to be considered a tap. Defaults to 0.25 seconds.
	 * @return True if the action was tapped, false otherwise.
	 */
	public function isTapped(actionId:String, maxDuration:Float = 0.25):Bool
	{
		return isJustReleasedWithDuration(actionId, 0, maxDuration);
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
					final impulse = _getImpulseFromSource(inputSource);
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
		if (FlxG.vcr.paused)
			return false;

		// 1. Handle exclusive logic
		if (trigger.exclusive != null && trigger.exclusive)
		{
			// If the number of currently active impulses does not exactly match the number of inputs
			// required by this exclusive trigger, then it cannot be active.
			if (_activeImpulses.size != trigger.inputs.length)
			{
				return false;
			}

			for (inputSource in trigger.inputs)
			{
				final impulse = _getImpulseFromSource(inputSource);
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
			var impulse = _getImpulseFromSource(inputSource);

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
				var lastImpulse = _getImpulseFromSource(trigger.inputs[trigger.inputs.length - 1]);
				if (lastImpulse == null || !_justPressedImpulses.contains(lastImpulse))
					return false; // Last key wasn't just pressed.

				// Since all inputs must be "just pressed" for the combo to be "just pressed",
				// their durations should all be 0. The order check from the `isPressed` logic
				// still applies, but `impulse1.duration >= impulse2.duration` will be `0 >= 0`, which is true.
				for (inputSource in trigger.inputs)
				{
					if (_getImpulseFromSource(inputSource).duration > 0)
					{
						return false;
					}
				}
			}
			else if (checkJustReleased)
			{
				// Handle "just released" for order-sensitive combos based on the `comboRelease` condition.
				final releaseCondition:ComboReleaseCondition = (trigger.comboRelease == Last) ? Last : Any;

				if (releaseCondition == Last)
				{
					// "LAST": Only the last key in the sequence being released triggers the event,
					// while all other keys are still held.
					var lastInput = trigger.inputs[trigger.inputs.length - 1];
					var lastImpulse = _getImpulseFromSource(lastInput);

					if (lastImpulse == null || !_justReleasedImpulses.contains(lastImpulse))
					{
						return false; // The last key was not just released.
					}

					// Check that all other keys are still active (held).
					for (i in 0...trigger.inputs.length - 1)
					{
						var impulse = _getImpulseFromSource(trigger.inputs[i]);
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
						var impulse = _getImpulseFromSource(inputSource);
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
					var impulse1 = _getImpulseFromSource(trigger.inputs[i]);
					var impulse2 = _getImpulseFromSource(trigger.inputs[i + 1]);
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

	private function isTriggerActiveWithDuration(trigger:InputTrigger, minDuration:Float, maxDuration:Float):Bool
	{
		if (FlxG.vcr.paused)
			return false;

		// This function is specifically for "just released" checks with duration.
		// We need to find at least one input in the trigger that was just released.
		var aKeyWasJustReleased = false;
		for (inputSource in trigger.inputs)
		{
			final impulse = _getImpulseFromSource(inputSource);
			if (impulse != null && _justReleasedImpulses.contains(impulse))
			{
				aKeyWasJustReleased = true;
				break;
			}
		}

		if (!aKeyWasJustReleased)
			return false;

		// 1. Handle exclusive logic
		if (trigger.exclusive != null && trigger.exclusive)
		{
			// For an exclusive trigger to be "just released", the number of inputs that are
			// either just-released or still-active must equal the number of inputs in the trigger.
			// And no other keys should be active.
			var relevantImpulseCount = 0;
			for (inputSource in trigger.inputs)
			{
				final impulse = _getImpulseFromSource(inputSource);
				if (impulse != null && (impulse.active || _justReleasedImpulses.contains(impulse)))
				{
					relevantImpulseCount++;
				}
			}

			if (relevantImpulseCount != trigger.inputs.length || (_activeImpulses.size + _justReleasedImpulses.size) != trigger.inputs.length)
			{
				return false;
			}
		}

		// 2. Handle orderSensitive logic
		if (trigger.orderSensitive != null && trigger.orderSensitive && trigger.inputs.length > 1)
		{
			final releaseCondition:ComboReleaseCondition = (trigger.comboRelease == Last) ? Last : Any;

			if (releaseCondition == Last)
			{
				// "LAST": Only the last key in the sequence being released triggers the event,
				// while all other keys are still held.
				var lastInput = trigger.inputs[trigger.inputs.length - 1];
				var lastImpulse = _getImpulseFromSource(lastInput);

				if (lastImpulse == null || !_justReleasedImpulses.contains(lastImpulse))
					return false; // The last key was not just released.

				// Check that all other keys are still active (held).
				for (i in 0...trigger.inputs.length - 1)
				{
					var impulse = _getImpulseFromSource(trigger.inputs[i]);
					if (impulse == null || !impulse.active)
						return false; // An earlier key in the sequence is not being held.
				}

				// Now, check the duration of the released key.
				return lastImpulse.duration >= minDuration && lastImpulse.duration <= maxDuration;
			}
			else // "ANY"
			{
				// "ANY": The combo is "just released" if it was fully active last frame,
				// and at least one key was released this frame.
				var justReleasedCount = 0;
				var activeCount = 0;
				var minHeldDuration:Float = Math.POSITIVE_INFINITY;

				for (inputSource in trigger.inputs)
				{
					var impulse = _getImpulseFromSource(inputSource);
					if (impulse != null)
					{
						if (_justReleasedImpulses.contains(impulse))
						{
							justReleasedCount++;
							minHeldDuration = Math.min(minHeldDuration, impulse.duration);
						}
						else if (impulse.active)
						{
							activeCount++;
							minHeldDuration = Math.min(minHeldDuration, impulse.duration);
						}
					}
				}

				if (justReleasedCount > 0 && (justReleasedCount + activeCount) == trigger.inputs.length)
				{
					// The duration of the combo is the minimum duration of all its (previously) active parts.
					return minHeldDuration >= minDuration && minHeldDuration <= maxDuration;
				}
				return false;
			}
		}
		else // Not order sensitive
		{
			// For non-combo or non-order-sensitive triggers, check if any just-released input meets the duration criteria.
			for (inputSource in trigger.inputs)
			{
				final impulse = _getImpulseFromSource(inputSource);
				if (impulse != null && _justReleasedImpulses.contains(impulse) && impulse.duration >= minDuration && impulse.duration <= maxDuration)
				{
					return true;
				}
			}
		}

		return false;
	}

	private function _getImpulseFromSource(source:InputSource):InputImpulse
	{
		var deviceId:Int = switch (source.device)
		{
			case InputDevice.Keyboard: 0;
			case InputDevice.Mouse: 1;
			default: -1;
		}

		if (deviceId == -1) return null;

		var code:Int = switch (source.device)
		{
			case InputDevice.Keyboard: FlxKey.fromString(source.code); // e.g., "A" -> 65
			case InputDevice.Mouse: MouseButton.stringToId(source.code); // e.g., "LMB" -> 0
			default: -1; // Or handle other devices like Gamepad
		}

		if (code == -1) return null;

		return _inputImpulses.get(_getImpulseKey(source.device, code));
	}

	private inline function _getImpulseKey(device:InputDevice, code:Int):Int
	{
		final deviceId:Int = (device == InputDevice.Mouse) ? 1 : 0; // Simplified for current devices
		return (deviceId << 24) | code;
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
