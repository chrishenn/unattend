# reference and WIP functionality for apps

$erroractionpreference = 'Continue'
$repo = "$PSScriptRoot\..\.." | Resolve-Path
(get-childitem "$repo/lib/*.ps1").foreach({. $_.FullName})
$rsc = "$repo\resources"

function uavolt_install {
    if (-not (installed 'universal audio volt driver')) {
        instexe "$inst\uavolt\setup.exe"
        rm -force -ea 0 "C:\programdata\microsoft\windows\start menu\programs\startup\Volt Driver Control Panel Autostart.lnk"
    }
}

function a4dj_install {
    if (-not (installed 'audio 4 dj driver')) {
        instexe "$inst\a4dj.exe"
    }
}

function shortcuts_install {
    cp -r -force $rsc\shortcuts ([System.Environment]::GetFolderPath("CommonStartMenu") + "\Programs")
}

function amesettings_install {
    scoop bucket add chris "https://github.com/chrishenn/scoops"
    scoop install chris/amesettings
}

function openshell_install {
    write-host 'importing openshell settings'
    scoop install chris/openshell
    [void](mkdir -force -ea 0 $env:programfiles\Open-Shell\Skins\)
    cp -force $rsc\openshell\Fluent-AME.skin7 $env:programfiles\Open-Shell\Skins\
    reg import $rsc\openshell\openshell.reg
}

function epatcher_install {
    if (-not (is_admin)) {
        error "$app requires admin rights to $cmd"
        break
    }
    $proc = start-process "$dir\ep_setup.exe" -NoNewWindow -passthru
    if (-not $proc.waitforexit(10000)) {
        error 'Failed installing explorerpatcher due to timeout (10 seconds)'
        break
    }
    write-host ''
    write-host -f y 'WARNING: ExplorerPatcher must be UNINSTALLED from an INTERACTIVE shell'
    write-host -f green 'The ExplorerPatcher installer may have killed your desktop shell. This is normal.'
    write-host -f green 'Please reboot to complete the installation'
}

function epatcher_uninstall {
    if (-not (is_admin)) {
        error "$app requires admin rights to $cmd"
        break
    }
    function interactive {
        $noni = [Environment]::GetCommandLineArgs() | Where-Object{ $_ -like '-NonI*' }
        return ([Environment]::UserInteractive -and -not $noni)
    }
    if (-not (interactive)) {
        write-host ''
        write-host -f y 'ExplorerPatcher has no silent uninstaller; you must launch from an interactive shell'
        write-host -f y 'and click through the uninstall dialogs in order to uninstall.'
        error 'ExplorerPatcher: Uninstalling from noninteractive shell is not supported'
        break
    }
    $proc = start-process "$dir\ep_setup.exe" -NoNewWindow -passthru -a '/uninstall'
    if (-not $proc.waitforexit(10000)) {
        error 'Failed uninstalling explorerpatcher due to timeout (10 seconds)'
        break
    }
}

function powertoys_install {
    write-host 'importing powertoys settings (note: manual settings application required)'
    scoop install powertoys
    [void](mkdir -force -ea 0 $env:userprofile\Documents\powertoys\backup)
    cp -force $rsc\powertoys\settings_*.ptb $env:userprofile\Documents\powertoys\backup\
}

function amecli_download {
    dra download -s 'CLI-Standalone.zip' -o amecli.zip Ameliorated-LLC/trusted-uninstaller-cli
    dra download -s 'AME-Beta-v{tag}.exe' -o "$repo\amegui.exe" Ameliorated-LLC/trusted-uninstaller-cli
    dra download -s 'Privacy+.v{tag}.apbx' -o "$repo\privacy.apbx" Ameliorated-LLC/privacy_plus

    7z x amecli.zip -o"$repo\amecli"
    rm amecli.zip
    7z x "$repo\privacy.apbx" -o"$repo\amecli\privacy" -pmalte
}

function ametools_install {
    cp -force ..\resources\ame_settings.exe $env:programdata\Ame
    cp -force ..\resources\appfetch.exe $env:programdata\Ame

    mkdir -force -ea 0 "$env:programdata\Microsoft\Windows\Start Menu\Programs\Ame"

    $s = (New-Object -ComObject WScript.Shell).CreateShortcut("$env:programdata\Microsoft\Windows\Start Menu\Programs\Ame\Ame Settings.lnk")
    $s.TargetPath = "$env:programdata\Ame\ame_settings.exe"
    $s.Save()
    $s = (New-Object -ComObject WScript.Shell).CreateShortcut("$env:programdata\Microsoft\Windows\Start Menu\Programs\Ame\App Fetch.lnk")
    $s.TargetPath = "$env:programdata\Ame\appfetch.exe"
    $s.Save()

    $appf = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AppFetch'
    setprop $appf 'DisplayName' 'String' 'App Fetch'
    setprop $appf 'Publisher' 'String' 'Ameliorated LLC'
    setprop $appf 'DisplayIcon' 'String' "$env:programdata\Ame\appfetch.exe"
    setprop $appf 'UninstallString' 'String' "$env:programdata\Ame\appfetch.exe --uninstall"
    setprop $appf 'NoRepair' 'DWORD' 1
    setprop $appf 'NoModify' 'DWORD' 1
    setprop $appf 'EstimatedSize' 'DWORD' 41062

    $sett = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Ame Settings'
    setprop $sett 'DisplayName' 'String' 'Ame Settings'
    setprop $sett 'Publisher' 'String' 'Ameliorated LLC'
    setprop $sett 'DisplayIcon' 'String' "$env:programdata\Ame\ame_settings.exe"
    setprop $sett 'UninstallString' 'String' "$env:programdata\Ame\ame_settings.exe --uninstall"
    setprop $sett 'NoRepair' 'DWORD' 1
    setprop $sett 'NoModify' 'DWORD' 1
    setprop $sett 'EstimatedSize' 'DWORD' 19558
}

function zen_backup (
    [string] $src,
    [string] $dst
) {
    cp -rf $src\chrome $dst
    cp -rf $src\extensions $dst
    cp -rf $src\storage $dst
    cp -f $src\*.sqlite $dst
    cp -f $src\*.sqlite-wal $dst
    cp -f $src\*.sqlite-shm $dst
    cp -f $src\*.mozlz4 $dst
    cp -f $src\*.sqlite-journal $dst
    cp -f $src\*.lz4 $dst
    cp -f $src\*.db $dst
}

function zen_install {
    $prof_src = "$repo\zen"
    if (! (test-path $prof_src)) {
        write-host -f y "no zen profile found under playbook\resources\zen. skipping profile install"
        return
    }

    $prof_tgt = "$HOME\scoop\persist\zen-browser"
    if (-not $prof_tgt) {
        write-host -f r "error: couldn't find system default installed profile dir"
        return 1
    }
    cp -r -force -ea 0 "$prof_src" "$prof_tgt"
    rm -force -ea 0 "$env:appdata\microsoft\windows\start menu\programs\{-brand-shortcut-name} Private Browsing.lnk"
}

function zen_default {
    # note: nonworking

    # probably best to use this
    # ref\appdefault.ps1 -ProgId $progid

    # key name not found. probably different in each install
    # this requires that UCPD has been disabled, with a reboot after

    # set zen as default browser
    $cls = get-childitem "REGISTRY::HKEY_USERS\S-1-5-21-574101447-4167929876-2884353096-1000_Classes" -recurse |
        where-object {$_.name -like "*FirefoxURL*"} |
        select-object -first 1
    $progid = $cls.name | split-path -leaf

    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice'
    SetProp $key ProgID 'String' $progid
    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice'
    SetProp $key ProgID 'String' $progid
    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\.avif\UserChoice'
    SetProp $key ProgID 'String' $progid
    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\.webp\UserChoice'
    SetProp $key ProgID 'String' $progid
    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\.htm\UserChoice'
    SetProp $key ProgID 'String' $progid
    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\.html\UserChoice'
    SetProp $key ProgID 'String' $progid
    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\.shtml\UserChoice'
    SetProp $key ProgID 'String' $progid
    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\.xhtml\UserChoice'
    SetProp $key ProgID 'String' $progid
    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\.pdf\UserChoice'
    SetProp $key ProgID 'String' $progid
}

function wt_rmmenu {
    # windows terminal manual remove right-click menu
    rm_menucmds 'SUBMENU0'
    rm_menus 'SUBMENU1'
    rm -r -force -ea 0 "$cstore\{SUBMENU2}"
    rm -r -force -ea 0 "$cstore\{SUBMENU4}"
    rm -r -force -ea 0 "$cstore\{SUBMENU3}"
}

function wt_addmenu {
    # windows terminal manual add right-click menu
    $rsc_src = "$bucketsdir\chris\scripts\$app\resources"
    $rsc = "$persist_dir\resources"
    [void](mkdir -force -ea 0 "$rsc")
    [void](cp -force "$rsc_src\*" -filter *.ico "$rsc")

    add_menucmds 'SUBMENU0' 'Terminal Here' "$rsc\term.ico" 'cmd.exe /c start wt -d "%V"'
    $cmd = @('{SUBMENU2}', 'Cmd', "$rsc\cmd.ico", 'cmd.exe /c start wt -p "Command Prompt" -d "%V"')
    $bash = @('{SUBMENU4}', 'Bash', "$rsc\bash.ico", 'cmd.exe /c start wt -p "Git Bash" -d "%V"')
    $pshell = @('{SUBMENU3}', 'Powershell', "$rsc\pshell.ico", 'cmd.exe /c start wt -p "Windows PowerShell" -d "%V"')

    $cstore = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell"
    add_menucmd $cstore @cmd
    add_menucmd $cstore @bash
    add_menucmd $cstore @pshell
    add_menus 'SUBMENU1' 'Terminal' "$rsc\term.ico" "$($cmd[0]);$($bash[0]);$($pshell[0])"

    $key = "HKLM:\Software\Classes\Directory\shell"
    SetProp $key '(Default)' 'String' 'Open'
    $key = 'HKLM:\Software\Classes\Directory\Background\shellex\ContextMenuHandlers\new_dir'
    SetProp $key '(Default)' 'String' '{D969A300-E7FF-11d0-A93B-00A0C90F2719}'
}

function wt_install {
    # windows terminal manual install
    write-host 'installing wt with right-click menu'
    scoop install jq git windows-terminal-preview pwsh

    # these installed target files are populated by someone else
    $rsc_tgt = "$HOME\scoop\persist\windows-terminal-preview\resources"

    # top-level menu item "terminal here" - launches terminal to default profile
    add_menucmds 'SUBMENU0' 'Terminal Here' "$rsc_tgt\term.ico" 'cmd.exe /c start wt.exe -d "%V"'

    # add submenu commands to command store
    $cmd = @('{SUBMENU2}', 'Cmd', "$rsc_tgt\cmd.ico", 'cmd.exe /c start wt.exe -p "Command Prompt" -d "%V"')
    $bash = @('{SUBMENU4}', 'Bash', "$rsc_tgt\bash.ico", 'cmd.exe /c start wt.exe -p "Git Bash" -d "%V"')
    $pshell = @('{SUBMENU3}', 'Powershell', "$rsc_tgt\pshell.ico", 'cmd.exe /c start wt.exe -p "Windows PowerShell" -d "%V"')

    $cstore = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell"
    Add_MenuCmd $cstore @cmd
    Add_MenuCmd $cstore @bash
    Add_MenuCmd $cstore @pshell

    # add a submenu pointing to command ids in command store
    add_menus 'SUBMENU1' 'Terminal' "$rsc_tgt\term.ico" "$($cmd[0]);$($bash[0]);$($pshell[0])"

    # fixup: set default action to Open, so that "Terminal Here" does not become the default double-click action for dirs
    $key = "HKLM:\Software\Classes\Directory\shell"
    SetProp $key '(Default)' 'String' 'Open'

    # fixup: "new folder" broken. Requires reboot to apply
    $key = 'HKLM:\Software\Classes\Directory\Background\shellex\ContextMenuHandlers\new_dir'
    SetProp $key '(Default)' 'String' '{D969A300-E7FF-11d0-A93B-00A0C90F2719}'
}

function ssh_install {
    # manual ssh_install is needed while scoop buckets install a nonworking sshd server. permissions issue
    write-host -f c "ssh_install"
    if (installed 'sshd') {
        write-host -f green "ssh_install: sshd already installed"
        return
    }

    scoop install 7zip git dra
    dra download -s 'OpenSSH-Win64.zip' -o ssh.zip powershell/win32-openssh
    7z x ssh.zip -ossh
    rm ssh.zip

    mv ssh/OpenSSH-Win64 ssh/OpenSSH
    cp -r -force ssh/OpenSSH C:\Windows\System32\
    rm -r -force ssh

    C:\Windows\System32\OpenSSH\install-sshd.ps1
    Set-Service ssh-agent -StartupType Disabled
    Set-Service sshd -StartupType Automatic
    Start-Service sshd

    # set openssh default login shell to pwsh
    # $path = (scoop shim info pwsh).path
    # SetProp 'HKLM:\SOFTWARE\OpenSSH' 'DefaultShell' 'String' "$path"

    # set openssh default login shell to cmd (needed for jetbrains remote)
    $path = (gcm cmd).path
    SetProp 'HKLM:\SOFTWARE\OpenSSH' 'DefaultShell' 'String' "$path"

    # git ssh config
    git config --system --unset credential.helper
    git config --global core.sshCommand 'C:/Windows/System32/OpenSSH/ssh.exe'
    [Environment]::SetEnvironmentVariable('GIT_SSH', 'C:\Windows\System32\OpenSSH\ssh.exe', 'Machine')
}

function op_install_msix {
    $url = "https://c.1password.com/dist/1P/win8/1PasswordSetup-latest.msixbundle"
    iwr $url -OutFile 1pass.msix -usebasicparsing
    add-appxpackage 1pass.msix -AllowUnsigned
    rm 1pass.msix
}

function op_install_msi {
    if (-not (installed "1password")) {
        write-host "installing 1Password GUI"
        $url = "https://downloads.1password.com/win/1PasswordSetup-latest.msi"
        iwr $url -outfile "1pass.msi" -usebasicparsing
        instexe msiexec '/i 1pass.msi'
        rm 1pass.msi
    }
}

function waves_ref {
    # not sure these are needed
    $script = @"
for /f "tokens=*" %%i in ('pnputil /enum-drivers ^| findstr /i waves') do (
    echo Deleting driver %%i
    for /f "tokens=2 delims=:" %%a in ("%%i") do (
        pnputil /delete-driver %%a /uninstall /force 2> nul
    )
)
"@
    set-content $script waves.bat
    Start-Process waves.bat -Wait -PassThru
    rm waves.bat

    # this may be equivalent to the final loop above
    # slow af
    # get-windowsdriver -online -all | where-object {$_.name -like "*waves*" }

    $drs = get-windowsdriver -online | where-object {$_.name -like "*waves*"}
    foreach ($dr in $drs) {
        pnputil /delete-driver $dr.OriginalFileName /uninstall
    }
}

function nvtray {
    write-host 'NVIDIA TRAY: hide nv tray icon'
    # https://www.elevenforum.com/t/fix-for-nvidia-taskbar-icon-missing.1853/
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm\NVTray'
    SetProp $key 'StartOnLogin' 'DWORD' 0
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak'
    SetProp $key 'DisableStoreNvCplNotifications' 'DWORD' 1

    if (get-process explorer -ea 0) {
        stop-process -name explorer -force
    }
}

function nvcontainer {
    # required for nvcontrol panel, but safe to disable and use nvapp instead
    svc_disable 'NVDisplay.ContainerLocalSystem'
}

function containers_client ($name) {
    $features = @("Containers", "microsoft-Hyper-V")
    $need_reboot = $false
    foreach ($feature in $features) {
        if ((Get-WindowsOptionalFeature -FeatureName $feature -Online).State -eq "Enabled") {
            Write-host "Windows optional feature '$feature' is already enabled."
        } else {
            Write-host "Windows optional feature '$feature' is not enabled. Enabling"
            DISM /Online /Enable-Feature /All /NoRestart /FeatureName:$feature
            $need_reboot = $true
        }
    }
    if ($need_reboot) {
        Write-host -f r "REBOOT REQUIRED TO ENABLE CONTAINER FEATURES"
    }
    return $need_reboot
}

function scoop_docker {
    containers_client
    scoop install docker docker-compose docker-buildx
    dockerd --register-service
    set-service docker -startuptype automatic
    start-service docker -ea 0
}
