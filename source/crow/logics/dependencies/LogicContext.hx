package crow.logics.dependencies;

import crow.logics.tools.ActionScope;

/**
 * A flexible context implementation for logic evaluation.
 */
class LogicContext implements ILogicContext
{
	private var _states:Map<String, LogicState>;

	public function new()
	{
		_states = new Map<String, LogicState>();
	}

	/**
	 * Helper to create a context compatible with the old 3-state system.
	 */
	public static function createLegacy(global:LogicState, ?local:LogicState, ?entity:LogicState):LogicContext
	{
		var ctx = new LogicContext();
		if (global != null)
			ctx.register(ActionScope.GLOBAL, global);
		if (local != null)
			ctx.register(ActionScope.LOCAL, local);
		if (entity != null)
			ctx.register(ActionScope.ENTITY, entity);
		return ctx;
	}

	public function register(scope:String, state:LogicState):Void
	{
		_states.set(scope, state);
	}

	public function unregister(scope:String):Void
	{
		_states.remove(scope);
	}

	public function getState(scope:String):LogicState
	{
		// Default to global if scope is null
		if (scope == null)
			scope = ActionScope.GLOBAL;

		return _states.get(scope);
	}
}

/**
 * Interface for providing LogicStates to evaluators based on a scope identifier.
 */
interface ILogicContext
{
	/**
	 * Retrieves a LogicState based on the provided scope name.
	 * @param scope The name of the scope (e.g., "global", "local", "settings").
	 * @return The requested LogicState, or null if not found.
	 */
	function getState(scope:String):LogicState;

    /**
     * Registers a LogicState with a given scope.
     * @param scope The name of the scope to register the state under.
     * @param state The LogicState to register.
     */
    function register(scope:String, state:LogicState):Void;

    /**
     * Unregisters a LogicState from a given scope.
     * @param scope The name of the scope to unregister.
     */
    function unregister(scope:String):Void;
}
