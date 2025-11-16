for /f "usebackq delims=" %%E in (`reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers" /s /f "WLIDCredentialProvider" ^| findstr /c:"Credential Providers\\"`) do reg delete "%%E" /f
ame-hexer "%WINDIR%\System32\en-US\credprovhost.dll.mui" "4F 00 74 00 68 00 65 00 72 00 20 00 75 00 73 00 65 00 72" "4C 00 6F 00 67 00 69 00 6E 00 00 00 00 00 00 00 00 00 00"
