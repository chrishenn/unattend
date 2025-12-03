function tray_hide (
    [Parameter(Mandatory = $false, HelpMessage = 'Program name to set hide value for')][string] $name,
    [Parameter(Mandatory = $false, HelpMessage = '{1: show, 0: hide (collapse)}')]
    [ValidateScript({
        if ($_ -lt 0 -or $_ -gt 1) {
            throw 'Invalid setting'
        } return $true
    })]
    [Int16] $val = 0,
    [Parameter(Mandatory = $false, HelpMessage = 'print all tray program entries: `tray -print $true`')]
    [switch] $print = $false
) {
    $key = 'HKCU:\Control Panel\NotifyIconSettings'
    $found = $false
    foreach ($GUID in (Get-ChildItem $key -Name)) {

        $child = "$key\$GUID"
        $exec = (Get-ItemProperty $child ExecutablePath -ea 0).ExecutablePath

        if ($print) {
            write-host -f c "key: $exec"
        }
        if (($name) -and ($exec -match $name)) {
            write-host -f green "Setting tray: {key: $child, val: $val, program: $name}"
            SetProp "$child" "IsPromoted" "DWord" $val
            $found = $true
            break
        }
    }
    if (($name) -and (-not $found)) {
        write-host "tray icon setting key for ($name) was not found"
    }
}

function trays_hide (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string[]] $names
) {
    foreach ($name in $names) {
        tray_hide "$name"
    }
}
