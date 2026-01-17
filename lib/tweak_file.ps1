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

function file_reparsepoints {
    # copied from schneegans unattend
    $paths = @(
        gci 'C:\' -force
        gci 'C:\Users' -force
        gci 'C:\Users\Default' -r -force -Depth 2
        gci 'C:\Users\Public' -r -force -Depth 2
        gci 'C:\ProgramData' -force
    )
    $rms = $paths | ? {$_.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint)}
    if ($rms) {
        rm -r -force $rms
    }
}

function file_clutter {
    # could possibly break old apps that rely on these being present
    file_rmf "$HOME\Contacts"
    file_rmf "$HOME\Favorites"
    file_rmf "$HOME\Links"
    file_rmf "$HOME\Music"
    file_rmf "$HOME\Pictures"
    file_rmf "$HOME\Recent"
    file_rmf "$HOME\Videos"
    file_rmf "$HOME\PrintHood"
    file_rmf "$HOME\NetHood"
    file_rmf "$HOME\Cookies"
    file_rmf "$HOME\Templates"
    file_rmf "$HOME\SendTo"
    file_rmf "$HOME\Documents\My Music"
    file_rmf "$HOME\Documents\My Pictures"
    file_rmf "$HOME\Documents\My Videos"
}

function file_misc {
    # installer files packaged into iso/$OEM$ are duplicated in these places
    file_rmf 'C:\windows\configsetroot\sources\$OEM$'
    file_rmf 'C:\windows\serviceprofiles\localservice\unattend'
    file_rmf 'C:\windows\serviceprofiles\networkservice\unattend'
    file_rmf 'C:\users\Default\unattend'

    # empty default folder
    file_rmf "$env:appdata\microsoft\windows\start menu\programs\maintenance"
    file_rmf "$env:userprofile\appdata\roaming\microsoft\windows\start menu\programs\maintenance"

    # not sure why this was there - possibly due to canceling AME while it's mid-run
    file_rmf 'C:\programdata\Ame'
    file_rmf 'C:\Windows\SystemApps\Microsoft.MicrosoftEdgeDevToolsClient_*'
}

function file_pins (
    [string] $here
) {
    # this had a race condition with user creation when run from unattend - probs run after first reboot
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
    $qa.NameSpace($here).self.invokeverb('pintohome')
}
