package backend.external;

@:headerInclude("windows.h")
@:headerInclude("winuser.h")
class ExternalCode
{
	/*@:functionCode('    
			DWORD BufSize = sizeof(DWORD);
			DWORD dwMHz = 0;
			HKEY hKey;

			if (RegOpenKeyEx(HKEY_LOCAL_MACHINE,
				"HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0",
				0, KEY_READ, &hKey) == ERROR_SUCCESS)
			{
				RegQueryValueEx(hKey, "~MHz", NULL, NULL,
					(LPBYTE)&dwMHz, &BufSize);

				RegCloseKey(hKey);
			}

			return dwMHz;
		') */
	public static function cpuClock():Float
	{
		return 0;
	}

	@:functionCode('
        SetProcessDPIAware();
    ')
	public static function registerAsDPICompatible() {}
}