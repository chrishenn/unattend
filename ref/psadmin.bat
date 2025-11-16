:: reference to show how to get admin from cmd and launch powershell with privileges

::-----------------------------------------------------------------------------------
echo off

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

:: --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo "Requesting Admin Elevation"
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    echo "Running as Admin"
    pushd "%CD%"
    CD /D "%~dp0"

:: --> Enable Scripts / Disable UAC
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& './disable_UAC.ps1'"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& './disable_ps_policy.ps1'"

::-----------------------------------------------------------------------------------
@echo "Batch 1 complete (Scripts Execution Policy, UAC Disable). Enter to restart..."
pause
start /wait shutdown /r /t 0
