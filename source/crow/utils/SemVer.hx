package crow.utils;

/**
 * A class for parsing, comparing, and managing semantic versioning (SemVer) strings.
 * Follows the SemVer 2.0.0 specification (https://semver.org/).
 * 
 * Format: MAJOR.MINOR.PATCH-PRERELEASE+BUILD
 * - MAJOR: Incremented for incompatible API changes.
 * - MINOR: Incremented for backward-compatible functionality.
 * - PATCH: Incremented for backward-compatible bug fixes.
 * - PRERELEASE: Optional, for pre-release versions (e.g., alpha, beta).
 * - BUILD: Optional, for build metadata.
 */
class SemVer
{
	/**
	 * The major version number.
	 */
	public final major:Int;

	/**
	 * The minor version number.
	 */
	public final minor:Int;

	/**
	 * The patch version number.
	 */
	public final patch:Int;

	/**
	 * The pre-release identifier (e.g., "alpha.1", "beta").
	 */
	public final prerelease:String;

	/**
	 * The build metadata (e.g., "build.123", "20230101").
	 */
	public final build:String;

	/**
	 * A regular expression for parsing a SemVer string.
	 */
	private static final SEMVER_REGEX = ~/^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$/;

	/**
	 * Creates a new SemVer instance.
	 * @param major The major version.
	 * @param minor The minor version.
	 * @param patch The patch version.
	 * @param prerelease Optional pre-release string.
	 * @param build Optional build metadata string.
	 */
	public function new(major:Int, minor:Int, patch:Int, ?prerelease:String, ?build:String)
	{
		this.major = major;
		this.minor = minor;
		this.patch = patch;
		this.prerelease = prerelease;
		this.build = build;
	}

	/**
	 * Parses a string into a SemVer object.
	 * @param versionString The string to parse (e.g., "1.2.3-alpha+001").
	 * @return A new SemVer object, or null if the string is invalid.
	 */
	public static function fromString(versionString:String):SemVer
	{
		if (versionString == null || !SEMVER_REGEX.match(versionString))
		{
			return null;
		}

		return new SemVer(Std.parseInt(SEMVER_REGEX.matched(1)), Std.parseInt(SEMVER_REGEX.matched(2)), Std.parseInt(SEMVER_REGEX.matched(3)),
			SEMVER_REGEX.matched(4), SEMVER_REGEX.matched(5));
	}

	/**
	 * Compares this version with another.
	 * @param other The SemVer object to compare against.
	 * @return -1 if this version is lower, 0 if they are equal in precedence, and 1 if this version is higher.
	 *         Note: Build metadata is ignored for precedence comparison.
	 */
	public function compareTo(other:SemVer):Int
	{
		if (major != other.major)
			return major > other.major ? 1 : -1;
		if (minor != other.minor)
			return minor > other.minor ? 1 : -1;
		if (patch != other.patch)
			return patch > other.patch ? 1 : -1;

		// A version without a pre-release has higher precedence than one with a pre-release.
		if (prerelease == null && other.prerelease != null)
			return 1;
		if (prerelease != null && other.prerelease == null)
			return -1;

		// Compare pre-release identifiers if both exist.
		if (prerelease != null && other.prerelease != null)
		{
			if (prerelease != other.prerelease)
			{
				// This is a simplified comparison. A full implementation would compare dot-separated identifiers.
				// For many use cases, string comparison is sufficient.
				return prerelease > other.prerelease ? 1 : -1;
			}
		}

		return 0; // Precedence is the same.
	}

	/**
	 * Returns the string representation of the version.
	 */
	public function toString():String
	{
		var s = '${major}.${minor}.${patch}';
		if (prerelease != null)
			s += '-${prerelease}';
		if (build != null)
			s += '+${build}';
		return s;
	}
}
