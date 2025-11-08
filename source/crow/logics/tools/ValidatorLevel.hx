package crow.logics.tools;

enum ValidatorLevel
{
	/**
	 * Validation is required and the predicate will not be evaluated if it is invalid.
	 */
	REQUIRED;

	/**
	 * Validation is optional, but a warning will be issued if the predicate is invalid.
	 */
	WARN;

	/**
	 * No validation is performed.
	 */
	NONE;
}