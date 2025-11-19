package crow.ecs.components;

import crow.ecs.systems.FieldLerpSystem;
import crow.ecs.components.BaseComponent;

/**
 * Smoothly interpolates a numerical field on the entity toward a target value,
 * using exponential smoothing: value = lerp(value, to, lerpPower * deltaTime).
 * 
 * The initial value is read from the field when the component is created.
 * This is NOT a timed tween – it's frame-rate independent smoothing.
 * 
 * Usage tip: Use FieldLerpComponent.lerpPowerFromDuration(desiredSeconds)
 * to approximate how much "smoothness" matches a time window.
 */
@:allow(FieldLerpSystem)
class FieldLerpComponent extends BaseComponent
{
	override function get_trait():ComponentTrait
	{
		return ComponentTrait.Multi;
	}

	/**
	 * Name of the numerical field on the entity to smooth (e.g. "x", "alpha").
	 */
	public var targetField(default, null):String;

	/**
	 * The value to smoothly approach.
	 * Can be updated at any time.
	 */
	public var to(default, set):Float;

	/**
	 * Interpolation strength per second (higher = faster).
	 * Should be > 0. Common range: 1.0 to 20.0.
	 */
	public var lerpPower(default, set):Float;

	/**
	 * Whether to clamp the lerp factor to avoid overshoot at low FPS.
	 */
	public var clampFactor:Bool = true;

	// Internal
	private var _currentValue:Float;

	public function new(entity:Entity, targetField:String, to:Float, lerpPower:Float = 5.0)
	{
		this.entity = entity;
		this.targetField = targetField;
		this.lerpPower = lerpPower;
		this.to = to;

		var val = Reflect.getProperty(entity, targetField);
		if (val == null || !Std.isOfType(val, Float))
			throw 'Field "$targetField" must exist and be numerical (Float).';

		this._currentValue = val;
	}

	function set_to(value:Float):Float
	{
		return this.to = value;
	}

	function set_lerpPower(value:Float):Float
	{
		if (value <= 0)
			throw "lerpPower must be > 0";
		return this.lerpPower = value;
	}

	// Used by the system
	private function getCurrentValue():Float
	{
		return _currentValue;
	}

	private function updateValue(newValue:Float):Void
	{
		_currentValue = newValue;

		Reflect.setProperty(entity, targetField, newValue);
	}

	/**
	 * Helper to estimate lerpPower from a desired "time to ~95% reach target".
	 * 
	 * For exponential smoothing, time to reach ~95% of target ~= 3 / lerpPower.
	 * So: lerpPower ~= 3 / durationInSeconds.
	 * 
	 * Example: lerpPowerFromDuration(1.0) => ~3.0 (reaches target in ~1 second).
	 */
	public static function lerpPowerFromDuration(durationSeconds:Float):Float
	{
		if (durationSeconds <= 0)
			durationSeconds = 0.01;
		return 3.0 / durationSeconds;
	}
}
