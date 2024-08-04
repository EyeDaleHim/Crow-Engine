package system.input;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionSet;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;

class Controls
{
	public static var manager:FlxActionManager;

	public static var actions(get, never):Array<ActionDigital>;

	static function get_actions():Array<ActionDigital>
	{
		var list:Array<ActionDigital> = [];

		for (control in Control.list)
		{
			list = list.concat(control.actions);
		}

		return list;
	}

	private static var rawKeyActions:Array<ActionDigital> = [];

	public static function init(Reset:Bool = false):Void
	{
		if (manager != null && !Reset)
			return;

		manager = new FlxActionManager();
		manager.resetOnStateSwitch = NONE;
		FlxG.inputs.add(manager);

		rawKeyActions = [];

		if (FlxG.save.data.binds == null)
		{
			FlxG.save.data.binds = new Map<String, Array<Int>>();
			FlxG.save.flush();

			Logs.info("No control binds saved, using default binds.");
		}

		var binds:Map<String, Array<Int>> = FlxG.save.data.binds;

		for (control in Control.list)
		{
			if (binds.exists(control.name))
			{
				control.keys = binds.get(control.name);
			}
			else
			{
				control.keys = control.defaultKeys;
			}
		}
	}

	public static function changeBind(control:Control, newKeys:Array<FlxKey>)
	{
		for (key in newKeys)
		{
			if (!FlxKey.toStringMap.exists(key))
				newKeys.remove(key);
		}

		if (newKeys[1] == newKeys[0])
			newKeys[1] = control.keys[1];

		control.keys = newKeys;

		for (action in control.actions)
		{
			action.removeAll();
			for (input in control.keys)
				action.addKey(input, action.savedState);
		}
	}

	public static function registerFunction(control:Control, state:FlxInputState, func:() -> Void, ?args:ActionArgs):ActionDigital
	{
		if (control != null)
		{
			args = ValidateUtils.validateActionArgs(args);

			var action:ActionDigital = new ActionDigital();
			action.controlOrigin = control;
			action.callback = function(_)
			{
				func();

				if (args?.once)
				{
					manager.removeAction(action, 0);
					control.actions.remove(action);
					action.destroy();
				}
			};

			action.savedState = state;

			action.persist = args.persist;

			control.actions.push(action);
			manager.addAction(action);

			for (input in control.keys)
			{
				action.addKey(input, state);
			}

			return action;
		}

		return null;
	}

	public static function registerToggle(control:Control, state:FlxInputState, parent:Dynamic, prop:String, ?args:ActionArgs):ActionDigital
	{
		registerFunction(control, invertState(state), function()
		{
			if (parent != null)
			{
				Reflect.setProperty(parent, prop, false);
			}
		}, args);

		return registerFunction(control, state, function()
		{
			if (parent != null)
			{
				Reflect.setProperty(parent, prop, true);
			}
		}, args);
	}

	public static function registerToggleArray(control:Control, state:FlxInputState, arr:Array<Bool>, index:Int, ?args:ActionArgs)
	{
		registerFunction(control, invertState(state), function()
		{
			if (arr?.length > 0)
			{
				arr[index] = false;
			}
		}, args);

		return registerFunction(control, state, function()
		{
			if (arr?.length > 0)
			{
				arr[index] = true;
			}
		}, args);
	}

	public static function registerRawKey(keys:Array<FlxKey>, state:FlxInputState, func:() -> Void, ?args:ActionArgs)
	{
		args = ValidateUtils.validateActionArgs(args);

		var action:ActionDigital = new ActionDigital();
		action.callback = function(_)
		{
			func();

			if (args?.once)
			{
				manager.removeAction(action, 0);
				rawKeyActions.remove(action);
				action.destroy();
			}
		};

		action.savedState = state;

		action.persist = args.persist;

		rawKeyActions.push(action);
		manager.addAction(action);

		for (key in keys)
		{
			action.addKey(key, state);
		}

		return action;
	}

	private static function invertState(state:FlxInputState):FlxInputState
	{
		return switch (state)
		{
			case PRESSED:
				RELEASED;
			case JUST_PRESSED:
				JUST_RELEASED;
			case RELEASED:
				PRESSED;
			case JUST_RELEASED:
				JUST_PRESSED;
		}
	}
}

class Control
{
	public static var list:Array<Control> = [];

	public static final UI_LEFT:Control = new Control("UI Left", [A, LEFT]);
	public static final UI_DOWN:Control = new Control("UI Down", [S, DOWN]);
	public static final UI_UP:Control = new Control("UI Up", [W, UP]);
	public static final UI_RIGHT:Control = new Control("UI Right", [D, RIGHT]);

	public static final NOTE_LEFT:Control = new Control("Note Left", [A, LEFT]);
	public static final NOTE_DOWN:Control = new Control("Note Down", [S, DOWN]);
	public static final NOTE_UP:Control = new Control("Note Up", [D, UP]);
	public static final NOTE_RIGHT:Control = new Control("Note Right", [F, RIGHT]);

	public static final ACCEPT:Control = new Control("Accept", [ENTER]);
	public static final BACK:Control = new Control("Back", [ESCAPE, BACKSPACE]);
	public static final PAUSE:Control = new Control("Pause", [ENTER, ESCAPE]);

	public var name:String = "";

	public var defaultKeys:Array<FlxKey> = [];
	public var keys:Array<FlxKey> = [];

	public var actions:Array<ActionDigital> = [];

	private function new(name:String, ?defaultKeys:Array<FlxKey>)
	{
		this.name = name;

		list.push(this);

		if (defaultKeys?.length > 0)
		{
			this.defaultKeys = defaultKeys;
		}
	}

	public function check():Bool
	{
		for (key in keys)
		{
			if (FlxKey.toStringMap.exists(key) && cast(key, Int) >= 0)
				return true;
		}
		return false;
	}
}

typedef ActionArgs =
{
	var ?persist:Bool;
	var ?once:Bool;
}
