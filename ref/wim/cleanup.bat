:: Clean up Windows 10 / 11
Echo Off & cls

(Net session >nul 2>&1)||(PowerShell start """%~0""" -verb RunAs & Exit /B)
Set ph=%~dp0
Cd %ph%

::  Apply the current user’s settings to the Default user:
Copy /Y unattend.xml  %SystemRoot%\System32\Sysprep

:: Delete existing shadow copies and restore points:
vssadmin delete shadows /All /Quiet

:: Clean up unused components and update files in the WinSxS folder:
Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase

:: Remove the Windows Update cache files:
del %windir%\SoftwareDistribution\Download\*.* /f /s /q

:: Perform a disk cleanup using the cleanmgr tool:
:: Empty the Recycle Bin in Windows:
PowerShell Clear-RecycleBin -Force
Cleanmgr /sagerun:1

:: Clear Event Viewer logs:
For /F "tokens=*" %%G in ('wevtutil.exe el') DO (call :do_clear "%%G")
Echo.
Echo  Event Logs Have Been Cleared!
Ping -n 5 127.0.0.1 >Nul
Goto :eof

:do_clear
Echo clearing %1
wevtutil.exe cl %1
Goto :eof
