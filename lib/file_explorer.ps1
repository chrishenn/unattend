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

function file_clutter {
    # could possibly break old apps that rely on these being present
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
}

function file_reparsepoints {
    # copied from unattend
    $paths = @(
        Get-ChildItem 'C:\' -force
        Get-ChildItem 'C:\Users' -force
        Get-ChildItem 'C:\Users\Default' -r -force -Depth 2
        Get-ChildItem 'C:\Users\Public' -r -force -Depth 2
        Get-ChildItem 'C:\ProgramData' -force
    )
    $rms = $paths | Where-Object {$_.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint)}
    rm -r -force $rms
}
