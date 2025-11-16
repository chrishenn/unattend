:: Remove Windows Media Player from default apps list
NSudoLC -U:T -P:E -M:S -Priority:RealTime -UseCurrentConsole -Wait CMD /c "for /f "usebackq delims=" %%A in (`reg query "HKCR" /f "WMP11*" ^| findstr /c:"WMP11"`) do reg delete "%%A" /f"
reg delete "HKCR\Applications\wmplayer.exe" /f

@echo off
for /f "usebackq delims=" %%A in (`reg query "HKCR" /k /f "AppX" ^| findstr /c:"AppX"`) do (
	reg query "%%A" /v "" | findstr /c:"DesktopStickerEditorCentennial" /c:"LogonWebHost" > NUL
		if not errorlevel 1 (
			reg delete "%%A" /f
		)
)

@echo on
bcdedit /set {default} bootmenupolicy legacy
bcdedit /set {current} recoveryenabled no
