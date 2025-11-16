@echo OFF

copy /y "%SystemRoot%\System32\svchost.exe" "%SystemRoot%\System32\amehost.exe"
if not exist "%SystemRoot%\System32\amehost.exe" (
    echo "Failed to copy amehost.exe file."
    exit /b 1
)
reg add "HKLM\System\CurrentControlSet\Services\CryptSvc" /v "ImagePath" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\amehost.exe -k NetworkService -p" /f
reg add "HKLM\System\CurrentControlSet\Services\lfsvc" /v "ImagePath" /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\amehost.exe -k netsvcs -p" /f
