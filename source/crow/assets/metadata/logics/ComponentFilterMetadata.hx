package crow.assets.metadata.logics;

import crow.assets.metadata.logics.PredicateMetadata;

/**
 * Defines criteria for selecting specific components when performing logic actions.
 */
typedef ComponentFilterMetadata =
{
    /**
     * If defined, only components that match this specific custom trait will be selected.
     */
    var ?customTrait:String;

    /**
     * A logic predicate to evaluate against the component's internal state.
     * 
     * In this context:
     * - "local" scope refers to the Component itself (e.g. checking `component.x`).
     * - "global" scope refers to the standard global state.
     * - "entity" scope refers to the owning entity's state.
     */
    var ?condition:PredicateMetadata;
}