function exe_lnk (
    [string][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $exe_path,
    [string][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $lnk_path
) {
    write-host -f c "Creating shortcut: '$lnk_path' for exe: '$exe_path'"
    $ws = New-Object -comObject WScript.Shell
    $short = $ws.CreateShortcut($lnk_path)
    $short.TargetPath = $exe_path
    $short.Save()
}
