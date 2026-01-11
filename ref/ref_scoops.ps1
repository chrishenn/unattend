# these apps were reimplemented as scoop manifests.
# See: https://github.com/chrishenn/scoops

$rsc = "$repo\resources"

function uavolt_install {
    if (-not (installed 'universal audio volt driver')) {
        appadd_exe "$inst\uavolt\setup.exe"
        rm -force -ea 0 "C:\programdata\microsoft\windows\start menu\programs\startup\Volt Driver Control Panel Autostart.lnk"
    }
}

function a4dj_install {
    if (-not (installed 'audio 4 dj driver')) {
        appadd_exe "$inst\a4dj.exe"
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
    # setprop 'HKLM:\SOFTWARE\OpenSSH' 'DefaultShell' 'String' "$path"

    # set openssh default login shell to cmd (needed for jetbrains remote)
    $path = (gcm cmd).path
    setprop 'HKLM:\SOFTWARE\OpenSSH' 'DefaultShell' 'String' "$path"

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
        appadd_exe msiexec '/i 1pass.msi'
        rm 1pass.msi
    }
}
