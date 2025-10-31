package crow.objects.layout;

/**
 * The direction to arrange child components in a `Layout`.
 */
enum abstract LayoutDirection(String) to String
{
	var VERTICAL = "VERTICAL";
	var HORIZONTAL = "HORIZONTAL";

	@:from
	public static function fromString(value:String):LayoutDirection
	{
		return switch (value.trim().toUpperCase())
		{
			case "VERTICAL":
				VERTICAL;
			case "HORIZONTAL":
				HORIZONTAL;
			default:
				{
					trace('Warning: Unknown LayoutDirection "$value". Defaulting to VERTICAL.');
					VERTICAL;
				}
		}
	}
}

/**
 * How to align children along the main axis.
 */
enum abstract JustifyContent(String) to String
{
	// Aligns children to the start of the main axis.
	var START = "START";

	// Aligns children to the end of the main axis.
	var END = "END";

	// Aligns children to the center of the main axis.
	var CENTER = "CENTER";

	// Aligns children with space distributed between them.
	var SPACE_BETWEEN = "SPACE_BETWEEN";

	// Aligns children with space distributed around them.
	var SPACE_AROUND = "SPACE_AROUND";

	// Aligns children with space distributed evenly.
	var SPACE_EVENLY = "SPACE_EVENLY";

	@:from
	public static function fromString(value:String):JustifyContent
	{
		return switch (value.trim().toUpperCase())
		{
			case "START":
				START;
			case "END":
				END;
			case "CENTER":
				CENTER;
			case "SPACE_BETWEEN":
				SPACE_BETWEEN;
			case "SPACE_AROUND":
				SPACE_AROUND;
			case "SPACE_EVENLY":
				SPACE_EVENLY;
			default:
				{
					trace('Warning: Unknown JustifyContent "$value". Defaulting to START.');
					START;
				}
		}
	}
}

/**
 * How to align children along the cross axis.
 */
enum abstract AlignItems(String) to String
{
	var START = "START";
	var END = "END";
	var CENTER = "CENTER";

	@:from
	public static function fromString(value:String):AlignItems
	{
		return switch (value.trim().toUpperCase())
		{
			case "START":
				START;
			case "END":
				END;
			case "CENTER":
				CENTER;
			default:
				{
					trace('Warning: Unknown AlignItems "$value". Defaulting to START.');
					START;
				}
		}
	}
}

/**
 * How the gap is applied between children.
 */
enum abstract GapBehavior(String) to String
{
	var AFTER_CHILD = "AFTER_CHILD";
	var FIXED_OFFSET = "FIXED_OFFSET";

	@:from
	public static function fromString(value:String):GapBehavior
	{
		return switch (value.trim().toUpperCase())
		{
			case "AFTER_CHILD":
				AFTER_CHILD;
			case "FIXED_OFFSET":
				FIXED_OFFSET;
			default:
				{
					trace('Warning: Unknown GapBehavior "$value". Defaulting to AFTER_CHILD.');
					AFTER_CHILD;
				}
		}
	}
}

/**
 * How to handle items that overflow the main axis.
 */
enum abstract FlexWrap(String) to String
{
	var NO_WRAP = "NO_WRAP";
	var WRAP = "WRAP";
	var WRAP_REVERSE = "WRAP_REVERSE";

	@:from
	public static function fromString(value:String):FlexWrap
	{
		return switch (value.trim().toUpperCase())
		{
			case "NO_WRAP":
				NO_WRAP;
			case "WRAP":
				WRAP;
			case "WRAP_REVERSE":
				WRAP_REVERSE;
			default:
				{
					trace('Warning: Unknown FlexWrap "$value". Defaulting to NO_WRAP.');
					NO_WRAP;
				}
		}
	}
}

/**
 * Defines how changing the `selectedIndex` in an `InteractableLayout` deals with boundaries.
 */
enum abstract SelectionMode(String) to String
{
	/**
	 * Selection wraps around from the last item to the first, and vice-versa.
	 */
	var WRAP = "WRAP";

	/**
	 * Selection stops at the first and last items.
	 */
	var BOUND = "BOUND";

	@:from
	public static function fromString(value:String):SelectionMode
	{
		return switch (value.trim().toUpperCase())
		{
			case "WRAP":
				WRAP;
			case "BOUND":
				BOUND;
			default:
				{
					trace('Warning: Unknown SelectionMode "$value". Defaulting to BOUND.');
					BOUND;
				}
		}
	}
}
