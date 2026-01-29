

# install the powershell module with helpful service functions

$module_folder = "custom_utils_module"

$modpaths = $env:PSModulePath -split(";")
$module_install_path = $modpaths[0]

if ( -not (test-path -path $module_install_path) ) {
    New-Item -ItemType Directory -Path $module_install_path
}

cp -r $module_folder $module_install_path




# copy the debloating and service scripts to the c:\boot\custom_.. directory
# create shortcuts for each script in the custom_.. folder in start Menu programs


$script_shortcut_dir = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\custom_utils"

$scripts_folder = "custom_scripts"
$script_install_dir = "C:\0LOCAL"
$script_install_path = $script_install_dir + '\' + $scripts_folder


# copy scripts to c:\boot\custom..
if ( -not (test-path -path $script_install_dir) ) {
    New-Item -ItemType Directory -Path $script_install_dir
}

cp -r $scripts_folder $script_install_dir


# generate start-menu shortcuts for each custom_script
if ( -not (test-path -path $script_shortcut_dir) ) {
    New-Item -ItemType Directory -Path $script_shortcut_dir
}

Get-ChildItem -Path $script_install_path -Filter *.ps1 -Name | ForEach-Object {

    $src_path = $script_install_path + '\' + $_
    $shortcut_path = $script_shortcut_dir + '\' + $_.split('\.')[0] + '.lnk'

    create_ps1_shortcut -SourcePs1Path $src_path -DestinationPath $shortcut_path
}



# copy custom_shortcuts folder to start menu

$custom_shortcut_install_dir = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
$custom_shortcut_folder = "custom_shortcuts"

cp -r $custom_shortcut_folder $custom_shortcut_install_dir
