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
    setprop $key '(Default)' 'String' 'Open'
    $key = 'HKLM:\Software\Classes\Directory\Background\shellex\ContextMenuHandlers\new_dir'
    setprop $key '(Default)' 'String' '{D969A300-E7FF-11d0-A93B-00A0C90F2719}'
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
    setprop $key '(Default)' 'String' 'Open'

    # fixup: "new folder" broken. Requires reboot to apply
    $key = 'HKLM:\Software\Classes\Directory\Background\shellex\ContextMenuHandlers\new_dir'
    setprop $key '(Default)' 'String' '{D969A300-E7FF-11d0-A93B-00A0C90F2719}'
}
