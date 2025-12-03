function InstallPortable (
    [Parameter(Mandatory = $true)][string]  $src,
    [Parameter(Mandatory = $false)][string] $dst = "C:\portable",
    [Parameter(Mandatory = $false)][string] $lnkdir = [System.Environment]::GetFolderPath("CommonStartMenu") + "\Programs\portable"
) {
    [void](mkdir -force -ea 0 $dst)
    [void](mkdir -force -ea 0 $lnkdir)
    cp -r -force $src $dst

    $src_name = split-path $src -Leaf
    $app_exes = Get-ChildItem "$dst\$src_name" -Filter *.exe
    if ($app_exes.count -eq 1) {
        $name_exe = split-path $app_exes -LeafBase
        write-host -f green "found exe: '$name_exe' for dir: '$src_name'"

        exe_lnk "$app_exes" "$lnkdir\$name_exe.lnk"
        return
    }
    foreach ($app_exe in $app_exes) {
        $name_exe = split-path $app_exe -LeafBase

        $srcn = $src_name.tolower()
        $namn = $name_exe.tolower()
        if ($srcn.contains($namn) -or $namn.contains($srcn)) {
            write-host -f green "found: '$app_exe' for: '$src_name'"
            exe_lnk "$app_exe" "$lnkdir\$name_exe.lnk"
            return
        }
    }
    foreach ($app_exe in Get-ChildItem -recurse "$dst\$src_name" -Filter *.exe) {
        $name_exe = split-path $app_exe -LeafBase

        $srcn = $src_name.tolower()
        $namn = $name_exe.tolower()
        if ($srcn.contains($namn) -or $namn.contains($srcn)) {
            write-host -f green "found: '$app_exe' for: '$src_name'"
            exe_lnk "$app_exe" "$lnkdir\$name_exe.lnk"
            return
        }
    }

    write-host -f r "ERROR: no matching exe found in $dst; no lnk will be created"
    return 1
}

function UninstallPortable (
    [Parameter(Mandatory = $true)][string]  $appdir,
    [Parameter(Mandatory = $false)][string] $lnkdir = [System.Environment]::GetFolderPath("CommonStartMenu") + "\Programs\portable"
) {
    rm -r -force $appdir
    if ($lnk = get-childitem $lnkdir | where-object {$_.name -match (split-path $appdir -leafbase)}) {
        rm -force $lnk
        write-host -f green "uninstalled portable: '$appdir'"
        return
    }
    write-host -f r "failed to uninstall portable: '$appdir'"
}
