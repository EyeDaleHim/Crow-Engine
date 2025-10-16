package gear.objects.layout;


class InteractableLayout extends Layout
{
	public static var addDefaultSignals:Bool = true;

	public static var defaultOnSelect:FlxObject->Void = null;
	public static var defaultOnDeselect:FlxObject->Void = null;
	public static var defaultOnIndex:Int->Int->Void = null;

	public var selectedIndex(default, set):Int = 0;

	public var selectionMode:SelectionMode = BOUND;

	public var onSelect:FlxTypedSignal<FlxObject->Void> = new FlxTypedSignal();
	public var onDeselect:FlxTypedSignal<FlxObject->Void> = new FlxTypedSignal();
	public var onIndex:FlxTypedSignal<Int->Int->Void> = new FlxTypedSignal();

	public var receiveSignals:Null<Bool> = null;

	public function new(x:Float = 0.0, y:Float = 0.0, ?direction:LayoutDirection, gap:Float = 0.0, padding:Float = 0.0)
	{
		super(x, y, direction, gap, padding);

		if (addDefaultSignals)
		{
			if (defaultOnSelect != null)
				onSelect.add(defaultOnSelect);

			if (defaultOnDeselect != null)
				onDeselect.add(defaultOnDeselect);

			if (defaultOnIndex != null)
				onIndex.add(defaultOnIndex);
		}
	}

	public function changeSelection(amount:Int):Void
	{
		if (members.length == 0)
			return;

		var newIndex = selectedIndex + amount;
		var nextInteractableIndex = findNextInteractable(newIndex, amount > 0 ? 1 : -1);

		if (nextInteractableIndex != -1)
		{
			switch (selectionMode)
			{
				case WRAP:
					selectedIndex = nextInteractableIndex;
				case BOUND:
					// findNextInteractable can wrap around, we only want to change if it's a valid move in the given direction
					if ((amount > 0 && nextInteractableIndex > selectedIndex)
						|| (amount < 0 && nextInteractableIndex < selectedIndex)
						|| members.length == 1)
					{
						selectedIndex = nextInteractableIndex;
					}
				default: // Future-proofing
					selectedIndex = nextInteractableIndex;
			}
		}
	}

	private function isInteractable(object:FlxObject):Bool
	{
		return object != null;
	}

	private function findNextInteractable(startIndex:Int, direction:Int):Int
	{
		if (members.length == 0)
			return -1;

		var currentIndex = startIndex;
		for (i in 0...members.length)
		{
			var wrappedIndex = FlxMath.wrap(currentIndex, 0, members.length - 1);
			if (isInteractable(members[wrappedIndex]))
			{
				return wrappedIndex;
			}
			currentIndex += direction;
		}

		return -1; // No interactable members found
	}

	private function set_selectedIndex(newIndex:Int):Int
	{
		if (members.length == 0)
		{
			if (selectedIndex != -1 && receiveSignals)
				onDeselect.dispatch(null); // Should not happen, but for safety
			return selectedIndex = -1;
		}

		var oldIndex = selectedIndex;
		var oldSelected = (oldIndex >= 0 && oldIndex < members.length) ? members[oldIndex] : null;

		if (oldSelected != null)
		{
			if (Std.isOfType(oldSelected, InteractableLayout))
			{
				cast(oldSelected, InteractableLayout).selectedIndex = -1; // Deselect everything in child
			}

			if (receiveSignals)
				onDeselect.dispatch(oldSelected);
		}

		selectedIndex = newIndex;
		var newSelected = (selectedIndex >= 0 && selectedIndex < members.length) ? members[selectedIndex] : null;

		if (newSelected != null)
		{
			if (receiveSignals)
				onSelect.dispatch(newSelected);

			// When a new item is selected, if it's a layout, it should have its first item selected by default.
			if (Std.isOfType(newSelected, InteractableLayout))
			{
				var childLayout:InteractableLayout = cast newSelected;
				childLayout.selectedIndex = 0; // Select first item in new child layout
			}
		}

		if (receiveSignals)
			onIndex.dispatch(oldIndex, selectedIndex);

		return selectedIndex;
	}
}
