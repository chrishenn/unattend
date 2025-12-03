enum Start {
    # boot = 0 # started by the system loader; only valid for device drivers
    # system = 1 # started by IOInitSystem; only valid for device drivers
    automatic = 2
    manual = 3
    disabled = 4
}

function svc_regfind (
    [string] $name
) {
    # match by service name, not by displayname. return found reg props
    $key = "HKLM:\SYSTEM\CurrentControlSet\Services"
    return (get-childitem $key | where-object {$_.PSChildName -match $name})
}

function svc_startup (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $name,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][Start] $startup
) {
    # set startup mode
    # usage: {svc_startup "csc" "disabled"} or {svc_startup "csc" 4} or {svc_startup "csc" ([Start]::disabled)}
    $key = "HKLM:\SYSTEM\CurrentControlSet\Services\$name"
    SetProp $key 'Start' 'DWORD' $([int]$startup)
}

function svcs_startup (
    [Parameter(Mandatory = $true)][string[]] $names,
    [Parameter(Mandatory = $true)][Start] $startup
) {
    foreach ($name in $names) {
        svc_startup "$name" ($startup)
    }
}

function svc_disable (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $name
) {
    stop-service -force -ea 0 "$name"
    svc_startup "$name" ([Start]::disabled)
}

function svcs_disable (
    [Parameter(Mandatory = $true)][string[]] $names
) {
    svcs_stop $names
    svcs_startup $names ([Start]::disabled)
}

function svc_rm (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $name
) {
    stop-service "$name" -force -ea 0
    svc_disable "$name"
    remove-service -ea 0 "$name"
}

function svcs_rm (
    [Parameter(Mandatory = $true)][string[]] $names
) {
    foreach ($name in $names) {
        svc_rm "$name"
    }
}

function svcs_start (
    [Parameter(Mandatory = $true)][string[]] $names
) {
    $names | ForEach-Object {Start-Service $_ -ea 0}
}

function svcs_stop (
    [Parameter(Mandatory = $true)][string[]] $names
) {
    $names | ForEach-Object {Stop-Service $_ -force -ea 0}
}

function svcs_stems (
    [Parameter(Mandatory = $true)][string[]] $stems
) {
    # pass array of strings, where service name starts with stem and ends in random string of chars
    # passed array is modified in-place with full service names
    for ($i = 0; $i -lt $stems.count; $i++) {
        $stem = $stems[$i]
        $svc_obj = get-service -Name "$stem*"
        $stems[$i] = $svc_obj.Name
    }
}
