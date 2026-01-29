function create_exe_shortcut
{
    param ( [Parameter(Mandatory=$true)][string]$ExePath, [Parameter(Mandatory=$true)][string]$ShortcutPath )

    " Creating shortcut for exe at: $ExePath"

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $ExePath
    $Shortcut.Save()
}
