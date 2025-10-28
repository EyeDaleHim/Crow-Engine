package gear.entities.managers;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

/**
 * Manages a collection of named `FlxTween` objects for an entity.
 * This allows for easy tracking, retrieval, and cleanup of tweens.
 */
class TweenManager implements IManager<FlxTween>
{
	public var list(default, null):Map<String, FlxTween>;

	public function new()
	{
		list = new Map<String, FlxTween>();
	}

	/**
	 * Adds a tween to the manager. If a tween with the same name
	 * already exists, it will be canceled and replaced.
	 */
	public function add(name:String, tween:FlxTween):Void
	{
		// If a tween with the same name exists, cancel it before replacing.
		if (list.exists(name))
		{
			final oldTween = list.get(name);
			oldTween.cancel();
			oldTween.destroy();
		}
		list.set(name, tween);
	}

	/**
	 * Creates a new tween, adds it to the manager, and returns it.
	 * @param name The unique name to identify the tween.
	 * @param object The object to tween.
	 * @param values The properties of the object to tween.
	 * @param duration The duration of the tween in seconds.
	 * @param options Optional tween options (e.g., ease, onComplete).
	 * @return The created `FlxTween` instance.
	 */
	public function tween(name:String, object:Dynamic, values:Dynamic, duration:Float, ?options:TweenOptions):FlxTween
	{
		final newTween = FlxTween.tween(object, values, duration, options);
		add(name, newTween);
		return newTween;
	}

	// TODO: Add other tween helpers like `color`, `angle`, `num`, etc.
	// public function color(...)
	// public function angle(...)

	public function get(name:String):Null<FlxTween>
	{
		return list.get(name);
	}

	/**
	 * Removes a tween from the manager and cancels it.
	 */
	public function remove(name:String):Bool
	{
		final tween = list.get(name);
		if (tween != null)
		{
			tween.cancel();
			tween.destroy();
			return list.remove(name);
		}
		return false;
	}

	/**
	 * Cancels and removes all managed tweens.
	 */
	public function clear():Void
	{
		for (tween in list)
		{
			tween.cancel();
			tween.destroy();
		}
		list.clear();
	}
}
