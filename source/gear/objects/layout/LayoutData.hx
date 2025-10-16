package gear.objects.layout;

import gear.objects.layout.LayoutProperties;

typedef LayoutData =
{
    /**
	 * Overrides the `alignItems` property of the parent Layout for this specific item.
	 */
    var ?alignSelf:AlignItems;
};