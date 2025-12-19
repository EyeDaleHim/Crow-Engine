package crow.objects.layout;

import crow.ecs.components.BaseComponent;
import crow.ecs.components.ValueRouterComponent;
import crow.objects.layout.InteractableLayout;

class DynamicListLayout extends InteractableLayout
{
	/**
	 * Lerp speed for position smoothing.
	 */
	public var lerpSpeed:Float = 9.6;

	/**
	 * Horizontal offset multiplier based on distance from selection.
	 * Legacy equivalent: 20.
	 */
	public var xOffset:Float = 20.0;

	/**
	 * Y offset multiplier for items. Legacy equivalent: 1.3
	 */
	public var yMultiplier:Float = 1.3;

	/**
	 * If true, the selected item is locked to the center of the Y axis (plus layout.y offset).
	 * If false, items flow downwards from layout.y.
	 */
	public var centerOnSelection:Bool = true;

	/**
	 * Target alpha for items that are not selected.
	 */
	public var deselectedAlpha:Float = 0.6;

	public function new(x:Float = 0.0, y:Float = 0.0)
	{
		super(x, y, VERTICAL, 0, 0);
		// Default spacing (gap) typically around 120 for FNF menus
		this.gap = 120;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (members.length == 0)
			return;

		var currentSel = (selectedIndex == -1) ? 0 : selectedIndex;

		for (i in 0...members.length)
		{
			var item = members[i];
			if (item == null || !item.exists)
				continue;

			// Distance: 0 = selected, positive = below, negative = above
			var distance:Float = i - currentSel;

			var targetY:Float;

			if (centerOnSelection)
			{
				// Centered flow, like FNF main menu
				targetY = (FlxG.height / 2) + (distance * yMultiplier * gap);
			}
			else
			{
				// Static flow, from top
				targetY = this.y + (i * gap);
			}

			// Calculate Target X
			// Base X + (Distance * Offset)
			var targetX:Float = this.x + (distance * xOffset);

			// Calculate Target Alpha
			var targetAlpha:Float = (i == currentSel) ? 1.0 : deselectedAlpha;

			// --- Apply Physics ---

			// We use a time-bound lerp to ensure framerate independence
			var lerpRatio = FlxMath.bound(elapsed * lerpSpeed, 0, 1);

			final model = cast(item, Entity).getModel();
			if (model != null)
			{
				model.x = FlxMath.lerp(model.x, targetX, lerpRatio);
				model.y = FlxMath.lerp(model.y, targetY, lerpRatio);
			}

			if (Std.isOfType(item, Entity))
			{
				var entity = cast(item, Entity);
				#if hl
				var valueRouters:Array<ValueRouterComponent> = [];
				var rawValueRouters:Array<IComponent> = entity.getComponentsByType(IComponent);

				for (router in rawValueRouters)
				{
					if (Std.isOfType(router, ValueRouterComponent))
						valueRouters.push(cast(router, ValueRouterComponent));
				}
				#else
				var valueRouters:Array<ValueRouterComponent> = cast entity.getComponentsByType(ValueRouterComponent);
				#end
				for (router in valueRouters)
				{
					if (router.field == "alpha")
					{
						var target = entity.getModel().spritesMap.get(router.target);
						if (target != null)
						{
							target.alpha = FlxMath.lerp(target.alpha, targetAlpha, lerpRatio);
						}
					}
				}
			}
			else if (Std.isOfType(item, FlxSprite))
			{
				var sprite:FlxSprite = cast item;
				sprite.alpha = FlxMath.lerp(sprite.alpha, targetAlpha, lerpRatio);
			}
		}
	}

	/**
	 * We override updateLayout to be empty because DynamicListLayout 
	 * calculates positions every frame in update(), not just on dirty flags.
	 */
	override public function updateLayout():Void
	{
		if (members.length == 0)
			return;
	}
}
