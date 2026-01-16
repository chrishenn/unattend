@echo off

for /f "usebackq tokens=2 delims=\" %%e in (`reg query "HKEY_USERS" ^| findstr /r /x /c:"HKEY_USERS\\S-.*" /c:"HKEY_USERS\\AME_UserHive_[^_]*"`) do (
	REM If the "Volatile Environment" key exists, that means it is a proper user. Built in accounts/SIDs do not have this key.
	reg query "HKU\%%e" | findstr /c:"Volatile Environment" /c:"AME_UserHive_" > nul 2>&1
	if not errorlevel 1 (
		call :USERREG "%%e"
	)
)

taskkill /f /im "OneDriveStandaloneUpdater.exe"
taskkill /f /im "Microsoft.SharePoint.exe"
taskkill /f /im "OneDriveSetup.exe"
taskkill /f /im "OneDrive.exe"
taskkill /f /im "FileCoAuth.exe"

for /f "usebackq delims=" %%a in (`dir /b /a:d "%SystemDrive%\Users"`) do (
	rmdir /q /s "%SystemDrive%\Users\%%a\AppData\Local\Microsoft\OneDrive"
	del /q /f "%SystemDrive%\Users\%%a\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"
)

for /f "usebackq delims=" %%a in (`dir /b /a:d "%SystemDrive%\Users"`) do (
	if exist "%SystemDrive%\Users\%%a\OneDrive\Desktop" dir /b /a:-s "%SystemDrive%\Users\%%a\OneDrive\Desktop" | findstr /R /c:"." > NUL 2>&1 || rmdir /q /s "%SystemDrive%\Users\%%a\OneDrive\Desktop"
	if exist "%SystemDrive%\Users\%%a\OneDrive\Documents" dir /b /a:-s "%SystemDrive%\Users\%%a\OneDrive\Documents" | findstr /R /c:"." > NUL 2>&1 || rmdir /q /s "%SystemDrive%\Users\%%a\OneDrive\Documents"
	if exist "%SystemDrive%\Users\%%a\OneDrive\Pictures" dir /b /a:-s "%SystemDrive%\Users\%%a\OneDrive\Pictures" | findstr /R /c:"." > NUL 2>&1 || rmdir /q /s "%SystemDrive%\Users\%%a\OneDrive\Pictures"
	if exist "%SystemDrive%\Users\%%a\OneDrive\Videos" dir /b /a:-s "%SystemDrive%\Users\%%a\OneDrive\Videos" | findstr /R /c:"." > NUL 2>&1 || rmdir /q /s "%SystemDrive%\Users\%%a\OneDrive\Videos"
	if exist "%SystemDrive%\Users\%%a\OneDrive\Music" dir /b /a:-s "%SystemDrive%\Users\%%a\OneDrive\Music" | findstr /R /c:"." > NUL 2>&1 || rmdir /q /s "%SystemDrive%\Users\%%a\OneDrive\Music"
	if exist "%SystemDrive%\Users\%%a\OneDrive" dir /b /a:-s "%SystemDrive%\Users\%%a\OneDrive" | findstr /R /c:"." > NUL 2>&1 || rmdir /q /s "%SystemDrive%\Users\%%a\OneDrive"
    del /q /f "%SystemDrive%\Users\%%a\OneDrive\Personal Vault.lnk"
)

for /f "usebackq delims=" %%e in (`reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SyncRootManager" ^| findstr /i /c:"OneDrive"`) do echo reg delete "%%e" /f & reg delete "%%e" /f
for /f "usebackq tokens=1* delims=\" %%A in (`schtasks /query /fo list ^| findstr /c:"\OneDrive Reporting Task" /c:"\OneDrive Standalone Update Task"`) do (
	schtasks /delete /tn "%%B" /f
)

exit /b 0

:USERREG
for /f "usebackq delims=" %%e in (`reg query "HKU\%~1\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\BannerStore" ^| findstr /i /c:"OneDrive"`) do (
	reg delete "%%e" /f
)
for /f "usebackq delims=" %%e in (`reg query "HKU\%~1\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers" ^| findstr /i /c:"OneDrive"`) do (
	reg delete "%%e" /f
)
for /f "usebackq delims=" %%e in (`reg query "HKU\%~1\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths" ^| findstr /i /c:"OneDrive"`) do (
	reg delete "%%e" /f
)
for /f "usebackq delims=" %%e in (`reg query "HKU\%~1\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" ^| findstr /i /c:"OneDrive"`) do (
	reg delete "%%e" /f
)
