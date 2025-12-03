package crow.ecs.systems;

import crow.ecs.components.BaseComponent;
import crow.ecs.components.FieldLerpComponent;
import crow.ecs.systems.BaseSystem;

class FieldLerpSystem extends BaseSystem
{
	override public function processEntity(entity:Entity, elapsed:Float):Void
	{
		#if hl
		// wtf is this shit workaround
		var lerps:Array<FieldLerpComponent> = [];
		var rawLerps:Array<IComponent> = entity.getComponentsByType(IComponent);

		for (lerp in rawLerps)
		{
			if (Std.isOfType(lerp, FieldLerpComponent))
				lerps.push(cast(lerp, FieldLerpComponent));
		}
		#else
		var lerps:Array<FieldLerpComponent> = cast entity.getComponentsByType(FieldLerpComponent);
		#end
		if (lerps == null)
			return;

		@:privateAccess
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

			postProcessComponent(lerp);
		}
	}
}
