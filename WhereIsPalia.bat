@echo off

echo Steam Compat Data Path:
echo %STEAM_COMPAT_DATA_PATH%

echo Prefix Path:
echo %WINEPREFIX%

echo Palia is installed in:
reg query HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall\Palia /v InstallLocation
pause
