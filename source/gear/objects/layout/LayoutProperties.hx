package gear.objects.layout;

/**
 * The direction to arrange child components in a `Layout`.
 */
enum abstract LayoutDirection(String) to String
{
	var VERTICAL = "VERTICAL";
	var HORIZONTAL = "HORIZONTAL";
}

/**
 * How to align children along the main axis.
 */
enum abstract JustifyContent(String) to String
{
	var START = "START";
	var END = "END";
	var CENTER = "CENTER";
	var SPACE_BETWEEN = "SPACE_BETWEEN";
	var SPACE_AROUND = "SPACE_AROUND";
	var SPACE_EVENLY = "SPACE_EVENLY";
}

/**
 * How to align children along the cross axis.
 */
enum abstract AlignItems(String) to String
{
	var START = "START";
	var END = "END";
	var CENTER = "CENTER";
}

/**
 * How the gap is applied between children.
 */
enum abstract GapBehavior(String) to String
{
	var AFTER_CHILD = "AFTER_CHILD";
	var FIXED_OFFSET = "FIXED_OFFSET";
}

/**
 * How to handle items that overflow the main axis.
 */
enum abstract FlexWrap(String) to String
{
	var NO_WRAP = "NO_WRAP";
	var WRAP = "WRAP";
	var WRAP_REVERSE = "WRAP_REVERSE";
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
}
