$shell_dir = "HKLM:\Software\Classes\Directory\shell"
$shell_back = "HKLM:\Software\Classes\Directory\Background\shell"

function add_menu (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $root_path,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $item_id,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $item_str,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $item_ico,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $item_subcmd_ids
) {
    ## Add items to right-click menu
    # Add simple submenu for shell item at root_path, with subcommands in cmd store at item_subcmd_ids
    $submenu_root = "$root_path\$item_id"
    setprop "$submenu_root" 'MUIVerb' "String" "$item_str"
    setprop "$submenu_root" 'Icon' "String" "$item_ico"
    setprop "$submenu_root" 'SubCommands' "String" "$item_subcmd_ids"
}

function add_menus (
    [string] $menustr,
    [string] $name,
    [string] $topico,
    [string] $subcmds
) {
    # add menu with subcmds to right click menu for: {directoy, background of file explorer}
    add_menu $shell_dir $menustr $name $topico $subcmds
    add_menu $shell_back $menustr $name $topico $subcmds
}

function add_menucmd (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $root_path,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $item_id,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $item_str,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $item_ico,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $item_cmd
) {
    # Add menu option for shell item at root_path, with command item_cmd
    $item_path = "$root_path\$item_id"
    $item_cmd_path = "$item_path\command"

    setprop $item_path 'Icon' "String" "$item_ico"
    setprop $item_path 'MUIVerb' "String" "$item_str"
    setprop $item_cmd_path '(default)' "String" "$item_cmd"
}

function add_menucmds (
    [string] $menustr,
    [string] $name,
    [string] $topico,
    [string] $cmd
) {
    # add menu with subcmds to right click menu for: {directoy, background of file explorer}
    add_menucmd $shell_dir $menustr $name $topico $cmd
    add_menucmd $shell_back $menustr $name $topico $cmd
}

function rm_menus (
    [string] $menustr
) {
    rm -r -force -ea 0 "$shell_dir\$menustr"
    rm -r -force -ea 0 "$shell_back\$menustr"
}

function rm_menucmds (
    [string] $menustr
) {
    rm -r -force -ea 0 "$shell_dir\$menustr"
    rm -r -force -ea 0 "$shell_back\$menustr"
}


