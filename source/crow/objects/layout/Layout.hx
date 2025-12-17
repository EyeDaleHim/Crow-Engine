package crow.objects.layout;

import crow.objects.layout.LayoutProperties;

class Layout extends UIComponent
{
	public var direction(default, set):LayoutDirection = VERTICAL;

	public var gap(default, set):Float = 0.0;
	public var padding(default, set):Float = 0.0;

	public var justifyContent(default, set):JustifyContent = START;
	public var alignItems(default, set):AlignItems = START;
	public var gapBehavior(default, set):GapBehavior = AFTER_CHILD;

	public var autoSize:Bool = true;
	public var wrap(default, set):FlexWrap = NO_WRAP;
	public var layoutData:Map<FlxObject, LayoutData> = new Map<FlxObject, LayoutData>();

	private var _totalChildrenSize:Float = 0;
	private var _numVisibleMembers:Int = 0;

	private var _isDirty:Bool = false;

	public function new(x:Float = 0.0, y:Float = 0.0, ?direction:LayoutDirection, gap:Float = 0.0, padding:Float = 0.0, ?gapBehavior:GapBehavior,
			?wrap:FlexWrap)
	{
		super(x, y);
		this.direction = direction ?? VERTICAL;
		this.padding = padding;
		this.gap = gap;
		this.gapBehavior = gapBehavior ?? AFTER_CHILD;
		this.wrap = wrap ?? NO_WRAP;

		invalidate();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (_isDirty)
		{
			_isDirty = false;
			updateLayout();
		}
	}

	public function updateLayout():Void
	{
		var visibleMembers:Array<FlxObject> = [];
		for (member in members)
		{
			if (member.exists && member.visible)
			{
				if (Std.isOfType(member, Layout))
				{
					cast(member, Layout).updateLayout();
				}
				visibleMembers.push(member);
			}
		}

		_numVisibleMembers = visibleMembers.length;

		var lines:Array<Array<FlxObject>> = [];
		if (_numVisibleMembers > 0)
		{
			if (wrap == NO_WRAP)
			{
				lines.push(visibleMembers);
			}
			else
			{
				var currentLine:Array<FlxObject> = [];
				var currentLineSize:Float = 0;
				var mainAxisLayoutSize:Null<Float> = (direction == HORIZONTAL) ? width : height;

				if (mainAxisLayoutSize == null)
				{
					// Cannot wrap without a forced size on the main axis
					lines.push(visibleMembers);
				}
				else
				{
					for (member in visibleMembers)
					{
						final layoutObject = getLayoutObject(member);
						var memberSize = (direction == HORIZONTAL) ? layoutObject.width : layoutObject.height;
						var memberGap = gap;
						if (Std.isOfType(member, UIComponent))
						{
							var uiComponent = cast(member, UIComponent);
							if (uiComponent.before.gap > 0)
							{
								memberGap = uiComponent.before.gap;
							}
							// 'after.gap' on the *previous* item would affect this gap,
							// but for simplicity in line-breaking, we only check 'before.gap' here.
						}

						if (currentLine.length > 0 && currentLineSize + memberGap + memberSize > mainAxisLayoutSize - (padding * 2))
						{
							lines.push(currentLine);
							currentLine = [];
							currentLineSize = 0;
						}

						currentLine.push(member);
						currentLineSize += memberSize + (currentLine.length > 1 ? memberGap : 0);
					}
					if (currentLine.length > 0)
					{
						lines.push(currentLine);
					}
				}
			}
		}

		if (wrap == WRAP_REVERSE)
		{
			lines.reverse();
		}

		var minX:Float = FlxMath.MAX_VALUE_FLOAT,
			minY:Float = FlxMath.MAX_VALUE_FLOAT;
		var maxX:Float = FlxMath.MIN_VALUE_FLOAT,
			maxY:Float = FlxMath.MIN_VALUE_FLOAT;
		var hasVisibleMember:Bool = false;

		var crossAxisOffset:Float = padding;

		for (line in lines)
		{
			hasVisibleMember = true;
			var lineMembers = line.length;
			var totalChildrenSize:Float = 0;
			var maxCrossAxisSize:Float = 0;

			for (member in line)
			{
				final layoutObject = getLayoutObject(member);

				switch (direction)
				{
					case VERTICAL:
						totalChildrenSize += layoutObject.height;
						if (layoutObject.width > maxCrossAxisSize)
							maxCrossAxisSize = layoutObject.width;
					case HORIZONTAL:
						totalChildrenSize += layoutObject.width;
						if (layoutObject.height > maxCrossAxisSize)
							maxCrossAxisSize = layoutObject.height;
				}
			}

			var totalGap = (lineMembers > 1) ? (lineMembers - 1) * gap : 0;
			var totalContentSize = totalChildrenSize + totalGap;

			var startPos:Float = padding;
			var justificationSpacing:Float = 0;

			var calcWidth = this.width;
			var calcHeight = this.height;
			var mainAxisSize = (direction == VERTICAL) ? calcHeight : calcWidth;
			var remainingSpace = mainAxisSize - totalContentSize - (padding * 2);

			if (wrap != NO_WRAP)
			{
				var mainAxisLayoutSize = (direction == HORIZONTAL) ? this.width : this.height;
				if (mainAxisLayoutSize > 0)
					remainingSpace = mainAxisLayoutSize - totalContentSize - (padding * 2);
			}

			if (remainingSpace > 0)
			{
				switch (justifyContent)
				{
					case START:
						// Default behavior, no change to startPos
					case END:
						startPos += remainingSpace;
					case CENTER:
						startPos += remainingSpace / 2;
					case SPACE_BETWEEN:
						if (lineMembers > 1)
							justificationSpacing = remainingSpace / (lineMembers - 1);
					case SPACE_AROUND:
						justificationSpacing = remainingSpace / lineMembers;
						startPos += justificationSpacing / 2;
					case SPACE_EVENLY:
						justificationSpacing = remainingSpace / (lineMembers + 1);
						startPos += justificationSpacing;
				}
			}

			var currentPos:Float = startPos;
			var crossAxisSize = (direction == VERTICAL) ? calcWidth : calcHeight;

			for (member in line)
			{
				final layoutObject = getLayoutObject(member);

				var memberGap = gap;
				if (Std.isOfType(member, UIComponent))
				{
					var uiComponent = cast(member, UIComponent);
					if (uiComponent.before.gap != 0)
					{
						var beforeGapAdjustment = uiComponent.before.overrideGap ? (uiComponent.before.gap - gap) : uiComponent.before.gap;
						currentPos += beforeGapAdjustment;
					}
					if (uiComponent.after.gap != 0)
					{
						memberGap = uiComponent.after.overrideGap ? uiComponent.after.gap : (gap + uiComponent.after.gap);
					}
				}

				// Determine alignment for this specific item
				var itemAlign = alignItems;
				if (layoutData.exists(member) && layoutData.get(member).alignSelf != null)
				{
					itemAlign = layoutData.get(member).alignSelf;
				}

				switch (direction)
				{
					case VERTICAL:
						layoutObject.y = this.y + currentPos;
						currentPos += layoutObject.height + memberGap + justificationSpacing;

						switch (itemAlign)
						{
							case START:
								layoutObject.x = this.x + crossAxisOffset;
							case END:
								layoutObject.x = this.x + crossAxisOffset + maxCrossAxisSize - layoutObject.width;
							case CENTER:
								layoutObject.x = this.x + crossAxisOffset + (maxCrossAxisSize - layoutObject.width) / 2;
						}

					case HORIZONTAL:
						layoutObject.x = this.x + currentPos;
						currentPos += layoutObject.width + memberGap + justificationSpacing;

						switch (itemAlign)
						{
							case START:
								layoutObject.y = this.y + crossAxisOffset;
							case END:
								layoutObject.y = this.y + crossAxisOffset + maxCrossAxisSize - layoutObject.height;
							case CENTER:
								layoutObject.y = this.y + crossAxisOffset + (maxCrossAxisSize - layoutObject.height) / 2;
						}
				}

				minX = Math.min(minX, layoutObject.x);
				minY = Math.min(minY, layoutObject.y);
				maxX = Math.max(maxX, layoutObject.x + layoutObject.width);
				maxY = Math.max(maxY, layoutObject.y + layoutObject.height);
			}
			crossAxisOffset += maxCrossAxisSize + gap;
		}

		if (autoSize)
		{
			// Update layout's own dimensions to fit its content.
			// This ensures the FlxObject's size is accurate for rendering and interaction,
			// even if a layout size is used for internal calculations.
			this.width = (hasVisibleMember ? (maxX - this.x) + padding : (padding * 2));
			this.height = (hasVisibleMember ? (maxY - this.y) + padding : (padding * 2));
		}
	}

	private function getLayoutObject(member:FlxObject):FlxObject
	{
		if (Std.isOfType(member, Entity))
		{
			var entity = cast(member, Entity);
			return entity.layoutTarget ?? entity.getModel();
		}
		return member;
	}

	public function getLayoutData(object:FlxObject):LayoutData
	{
		if (!layoutData.exists(object))
		{
			layoutData.set(object, {});
		}
		return layoutData.get(object);
	}

	public function setLayoutData(object:FlxObject, data:LayoutData):Void
	{
		layoutData.set(object, data);
	}

	public function getMembers<T:FlxObject>(?type:T, ?condition:T->Bool):Array<T>
	{
		var result:Array<T> = [];
		for (member in members)
		{
			if ((Std.isOfType(member, type) || type == null) && (condition == null || condition(cast member)))
			{
				result.push(cast member);
			}
		}
		return result;
	}

	public function screenCenterWithMembers(axes:FlxAxes = FlxAxes.XY):Void
	{
		updateLayout();

		var newX = x;
		var newY = y;

		if (axes.x)
			newX = (FlxG.width / 2) - (width / 2);
		if (axes.y)
			newY = (FlxG.height / 2) - (height / 2);

		repositionMembers(newX, newY);
	}

	public function centerOn(target:FlxObject, axes:FlxAxes = FlxAxes.XY):Void
	{
		updateLayout();

		var newX = x;
		var newY = y;

		if (axes.x)
			newX = target.x + (target.width / 2) - (width / 2);
		if (axes.y)
			newY = target.y + (target.height / 2) - (height / 2);

		repositionMembers(newX, newY);
	}

	private function repositionMembers(newX:Float, newY:Float):Void
	{
		var dx = newX - x;
		var dy = newY - y;
		x = newX;
		y = newY;
		for (member in members)
		{
			member.x += dx;
			member.y += dy;
		}
	}

	override public function add<T:FlxObject>(Object:T):T
	{
		group.add(Object);
		invalidate();
		return Object;
	}

	override public function remove<T:FlxObject>(Object:T):T
	{
		group.remove(Object);
		layoutData.remove(Object);
		invalidate();
		return Object;
	}

	public function invalidate():Void
	{
		_isDirty = true;
	}

	private function set_direction(value:LayoutDirection):LayoutDirection
	{
		direction = value;
		invalidate();
		return direction;
	}

	private function set_gap(value:Float):Float
	{
		gap = value;
		invalidate();
		return gap;
	}

	private function set_padding(value:Float):Float
	{
		padding = value;
		invalidate();
		return padding;
	}

	private function set_justifyContent(value:JustifyContent):JustifyContent
	{
		justifyContent = value;
		invalidate();
		return justifyContent;
	}

	private function set_alignItems(value:AlignItems):AlignItems
	{
		alignItems = value;
		invalidate();
		return alignItems;
	}

	private function set_gapBehavior(value:GapBehavior):GapBehavior
	{
		gapBehavior = value;
		invalidate();
		return gapBehavior;
	}

	private function set_wrap(value:FlexWrap):FlexWrap
	{
		wrap = value;
		invalidate();
		return wrap;
	}
}
