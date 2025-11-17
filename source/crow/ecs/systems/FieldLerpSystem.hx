package crow.ecs.systems;

import crow.ecs.components.FieldLerpComponent;
import crow.ecs.systems.BaseSystem;

class FieldLerpSystem extends BaseSystem
{
	override public function processEntity(entity:Entity, elapsed:Float):Void
	{
		var lerps:Array<FieldLerpComponent> = cast entity.getComponentsByType(FieldLerpComponent);
		if (lerps == null)
			return;

		for (lerp in lerps)
		{
			var current = lerp.getCurrentValue();
			var target = lerp.to;
			var power = lerp.lerpPower;

			var factor = power * elapsed;
			if (lerp.clampFactor && factor > 1.0)
				factor = 1.0;

			var newValue = current + (target - current) * factor;
			lerp.updateValue(newValue);
		}
	}
}
