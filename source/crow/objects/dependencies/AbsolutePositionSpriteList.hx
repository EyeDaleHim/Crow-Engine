package crow.objects.dependencies;

import crow.objects.dependencies.AbsolutePositionSprite;

/**
 * A `FlxTypedContainer` for `AbsolutePositionSprite` objects.
 * 
 * The way each member is drawn is done differently, as each member's position
 * is relative to its parent's position.
 */
class AbsolutePositionSpriteList extends FlxTypedContainer<AbsolutePositionSprite>
{
	// Position of the list
	public var x(default, set):Float = 0.0;
	public var y(default, set):Float = 0.0;

	// Size of the list is determined by its members, including its relative position translated to
	// world space, and size.
	public var width(get, null):Float = 0.0;
	public var height(get, null):Float = 0.0;

	public var alpha(default, set):Float = 1.0;

	/**
	 * Set the position of the list.
	 * @param x 
	 * @param y 
	 * @return `this` object for chaining.
	 */
	public function setPosition(x:Float, y:Float):AbsolutePositionSpriteList
	{
		this.x = x;
		this.y = y;

		return this;
	}

	/**
	 * Center the list on the screen along the given axis.
	 * @param axe 
	 * @return `this` object for chaining.
	 */
	public function screenCenter(axe:FlxAxes):AbsolutePositionSpriteList
	{
		if (axe.x)
		{
			x = (FlxG.width - width) / 2;
		}

		if (axe.y)
		{
			y = (FlxG.height - height) / 2;
		}

		return this;
	}

	public function cameraCenter(axe:FlxAxes):AbsolutePositionSpriteList
	{
		if (axe.x)
		{
			x = (getDefaultCamera().width - width) / 2;
		}

		if (axe.y)
		{
			y = (getDefaultCamera().height - height) / 2;
		}

		return this;
	}

	private function set_x(value:Float):Float
	{
		forEach((member) ->
		{
			@:privateAccess
			member._internalOffset.x = value;
		});

		return x = value;
	}

	private function set_y(value:Float):Float
	{
		forEach((member) ->
		{
			@:privateAccess
			member._internalOffset.y = value;
		});

		return y = value;
	}

	private function get_width():Float
	{
		var minX:Float = Math.POSITIVE_INFINITY;
		var maxX:Float = Math.NEGATIVE_INFINITY;

		forEach((member) ->
		{
			final memberX:Float = member.x - x;
			if (memberX < minX)
			{
				minX = memberX;
			}
			if (memberX + member.width > maxX)
			{
				maxX = memberX + member.width;
			}
		});

		if (minX == Math.POSITIVE_INFINITY) // No members in the list
		{
			return 0.0;
		}

		return maxX - minX;
	}

	private function get_height():Float
	{
		var minY:Float = Math.POSITIVE_INFINITY;
		var maxY:Float = Math.NEGATIVE_INFINITY;

		forEach((member) ->
		{
			final memberY:Float = member.y - y;
			if (memberY < minY)
			{
				minY = memberY;
			}
			if (memberY + member.height > maxY)
			{
				maxY = memberY + member.height;
			}
		});

		if (minY == Math.POSITIVE_INFINITY) // No members in the list
		{
			return 0.0;
		}

		return maxY - minY;
	}

	private function set_alpha(value:Float):Float
	{
		forEach((member) ->
		{
			@:privateAccess
			member._internalAlphaMult = value;
		});

		return alpha = value;
	}
}
