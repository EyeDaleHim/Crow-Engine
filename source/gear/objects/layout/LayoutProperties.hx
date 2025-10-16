package gear.objects.layout;

/**
 * The direction to arrange child components in a `Layout`.
 */
enum LayoutDirection
{
	VERTICAL;
	HORIZONTAL;
}

/**
 * How to align children along the main axis.
 */
enum JustifyContent
{
	START;
	END;
	CENTER;
	SPACE_BETWEEN;
	SPACE_AROUND;
	SPACE_EVENLY;
}

/**
 * How to align children along the cross axis.
 */
enum AlignItems
{
	START;
	END;
	CENTER;
}

/**
 * How the gap is applied between children.
 */
enum GapBehavior
{
	AFTER_CHILD;
	FIXED_OFFSET;
}

/**
 * How to handle items that overflow the main axis.
 */
enum FlexWrap
{
	NO_WRAP;
	WRAP;
	WRAP_REVERSE;
}

/**
 * Defines how changing the `selectedIndex` in an `InteractableLayout` deals with boundaries.
 */
enum SelectionMode
{
	WRAP; // Selection wraps around from the last item to the first, and vice-versa.
	BOUND; // Selection stops at the first and last items.
}
