param(
    [string][ValidateNotNullOrEmpty()] $user,
    [string][ValidateNotNullOrEmpty()] $pass
)

$erroractionpreference = 'Continue'
$ConfirmPreference = 'None'
$repo = $PSScriptRoot
Start-Transcript -Append "$repo\log2.txt"
(get-childitem "$repo\lib\*.ps1").foreach({. $_.FullName})
$cfg = cfg_yml "$repo\cfg.yml"

function file_rm {
    rm_force "$HOME\Contacts"
    rm_force "$HOME\Favorites"
    rm_force "$HOME\Links"
    rm_force "$HOME\Music"
    rm_force "$HOME\Pictures"
    rm_force "$HOME\Recent"
    rm_force "$HOME\Videos"
    rm_force "$HOME\PrintHood"
    rm_force "$HOME\NetHood"
    rm_force "$HOME\Cookies"
    rm_force "$HOME\Templates"
    rm_force "$HOME\SendTo"
    rm_force "$HOME\Documents\My Music"
    rm_force "$HOME\Documents\My Pictures"
    rm_force "$HOME\Documents\My Videos"

    # probably a bit too risky. these are for backwards-compatibility with ancient programs
    # rm_force "$HOME\My Documents"
    # rm_force "$HOME\Start Menu"
    # rm_force "$HOME\Application Data"
    # rm_force "$HOME\Local Settings"

    # installer files packaegd into iso/$OEM$ are duplicated in these places
    rm_force 'C:\windows\configsetroot\sources\$OEM$'
    rm_force 'C:\windows\serviceprofiles\localservice\unattend'
    rm_force 'C:\windows\serviceprofiles\networkservice\unattend'
    rm_force 'C:\users\Default\unattend'

    # empty default folder
    rm_force "$env:appdata\microsoft\windows\start menu\programs\maintenance"
    rm_force "$env:userprofile\appdata\roaming\microsoft\windows\start menu\programs\maintenance"

    # not sure why this was there
    rm_force 'C:\programdata\Ame'
    rm_force 'C:\Windows\SystemApps\Microsoft.MicrosoftEdgeDevToolsClient_*'
}

function file_pins {
    # unpin all from quick access. NOTE: this is the "frequent folders" namespace!
    $qa = new-object -com shell.application
    $pins = $qa.NameSpace('shell:::{3936E9E4-D92C-4EEE-A85A-BC16D5EA0819}').items() | where {$_.IsFolder -eq 'True'}
    if ($pins) {
        $pins.InvokeVerb('unpinfromhome')
    }

    # create new home
    $nhome = "C:\home\$env:user"
    $homeps = @("$nhome\Projects", "$nhome\Documents", "$nhome\Downloads")
    foreach ($homep in $homeps) {
        [void](mkdir -force -ea 0 $homep)
    }
    foreach ($homep in $homeps) {
        $qa.NameSpace($homep).self.invokeverb('pintohome')
    }
    $qa.NameSpace($repo).self.invokeverb('pintohome')
}

function file_extensions {
    # show extensions
    # [void](rp -force -ea 0 'registry::HKEY_CLASSES_ROOT\lnkfile' 'NeverShowExt')
    [void](rp -force -ea 0 'registry::HKEY_CLASSES_ROOT\InternetShortcut' 'NeverShowExt')
    [void](rp -force -ea 0 'registry::HKEY_CLASSES_ROOT\piffile' 'NeverShowExt')
    [void](rp -force -ea 0 'registry::HKEY_CLASSES_ROOT\SHCmdFile' 'NeverShowExt')
    [void](rp -force -ea 0 'registry::HKEY_CLASSES_ROOT\ShellScrap' 'NeverShowExt')
    [void](rp -force -ea 0 'registry::HKEY_CLASSES_ROOT\DocShortcut' 'NeverShowExt')
    [void](rp -force -ea 0 'registry::HKEY_CLASSES_ROOT\xnkfile' 'NeverShowExt')
}

function setup2 {
    write-host -f cyan "setup2 begin"

    file_rm
    file_pins
    file_extensions

    alienware
    waves
    killer
    edgeupdate
    dpst
    startups_rm @('SecurityHealth', 'Volt Driver Control Panel Autostart', 'waves')
    trays_hide @('universalaudio')

    scoop_boot_private $cfg
    chezmoi init chrishenn --apply --force
    & "$repo\amecli\TrustedUninstaller.CLI.exe" "$repo\playbook" ''

    write-host -f green "setup2 done"
}

autologin $user $pass
setup2
restart-computer -f
