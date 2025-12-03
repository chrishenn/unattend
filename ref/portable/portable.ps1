(get-childitem "$PSScriptRoot/../lib/*.ps1").foreach({. $_.FullName})

function ptbs_install_clean {
    $src = "$psscriptroot\portable"
    $dst = 'C:\portable'

    foreach ($dirname in (Get-ChildItem $src -Directory -Name)) {
        if (get-childitem -ea 0 $dst -directory -filter $dirname) {
            write-host -f c "uninstalling portable in: '$dst' for: '$dirname'"
            UninstallPortable "$dst\$dirname"
        }
        write-host -f c "installing portable: $dirname"
        InstallPortable "$src\$dirname" 'C:\portable'
    }
}

function ptbs_uninstall {
    $src = "$psscriptroot\portable"
    $dst = 'C:\portable'

    foreach ($dirname in (Get-ChildItem $src -Directory -Name)) {
        if (get-childitem -ea 0 $dst -directory -filter $dirname) {
            write-host -f c "uninstalling portable in: '$dst' for: '$dirname'"
            UninstallPortable "$dst\$dirname"
        }
    }
}

ptbs_install_clean
