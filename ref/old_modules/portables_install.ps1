#### Portable apps automatic installer


## install the powershell module with helpful functions

$module_folder = "custom_portables_module"
$modpaths = $env:PSModulePath -split(";")
$module_install_path = $modpaths[0]

if ( -not (test-path -path $module_install_path) ) {
    New-Item -ItemType Directory -Path $module_install_path
}

cp -r $module_folder $module_install_path




## install portable app folders to C:\BOOT\portable_apps

$portable_install_root = "C:\0LOCAL"
$portable_folder = "portable_apps"
$portable_install_path = $portable_install_root + '\' + $portable_folder

if ( -not (test-path -path $portable_install_root) ) {
    New-Item -ItemType Directory -Path $portable_install_root
}

cp -r $portable_folder $portable_install_root



## for each portable app, generate an appropriate shortcut, place in start menu
## looks for exe name in folder name and vice-versa. If no match but only one exe in folder, then
## uses that as launch exe to make shortcut

$shortcut_root = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
$portable_shortcut_folder = "portable_apps"
$portable_shortcut_install_root = $shortcut_root + '\' + $portable_shortcut_folder

if ( -not (test-path -path $portable_shortcut_install_root) ) {
    New-Item -ItemType Directory -Path $portable_shortcut_install_root
}

foreach ( $folder in (Get-ChildItem -Path $portable_install_path -Directory -Name) )
{
        $app_dir = $portable_install_path + '\' + $folder

        $found = $false
        $app_exes = Get-ChildItem -Path $app_dir -Filter *.exe -Name
        foreach ($app_exe in $app_exes)
        {
            $name_exe = $app_exe.split('\.')[0]

            if ( $folder.tolower().contains($name_exe.tolower()) -or $name_exe.tolower().contains($folder.tolower()) ) {

                " Using shortcut to $app_exe for $folder "
                $src_path = $app_dir + '\' + $app_exe
                $shortcut_path = $portable_shortcut_install_root + '\' + $name_exe + '.lnk'

                create_exe_shortcut -ExePath $src_path -ShortcutPath $shortcut_path
                $found = $true
                break
            }
        }

        if ( (-not $found) -and ($app_exes.count -eq 1) ) {

                $app_exe = $app_exes
                $name_exe = $app_exe.split('\.')[0]

                " Using shortcut to $app_exe for $folder "
                $src_path = $app_dir + '\' + $app_exe
                $shortcut_path = $portable_shortcut_install_root + '\' + $name_exe + '.lnk'

                create_exe_shortcut -ExePath $src_path -ShortcutPath $shortcut_path
                $found = $true
        } elseif (-not $found) {
            "", ""
            "Caution!: NO Shortcut made for $folder !!!!!"
            ", "
        }
}
