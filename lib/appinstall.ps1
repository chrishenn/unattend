function sys_app (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $name
) {
    # slow; deprecated. use reg_app instead
    return (Get-ciminstance Win32_Product | Where-Object {$_.Name -match "$name"} | measure).count -gt 0
}

function gcm_app (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $name
) {
    if (gcm $name -ea 0) {
        return $true
    }
    return $false
}

function scoop_app (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $name
) {
    if (-not (gcm_app scoop)) {
        return $false
    }
    return ((scoop export | ConvertFrom-Json).apps | where-object {$_.name -eq "$name"} | measure).count -gt 0
}

function reg_app (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $name
) {
    $apps = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $apps += Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    return ($apps | Where-Object {$_.displayname -match "$name"} | measure).count -gt 0
}

function installed (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $name
) {
    # note: scoop_app matches name exactly (case-insensitive)
    # sys_app/reg_app matches on "real app name -match (contains) $name"
    # gcm passes $name directly to powershell `get-command $name`
    return (reg_app $name) -or (scoop_app $name) -or (gcm_app $name)
}

function instexe (
    [string] $exe,
    [string] $arg = '/i /quiet /passive /S /qn /silent',
    [int] $timeoutms = 60000
) {
    # silent install from exe with 1-minute timeout
    write-host -f cyan "installing with 1-minute timeout: $exe"
    $proc = start-process "$exe" -ArgumentList "$arg" -NoNewWindow -passthru
    if (-not ($proc.waitforexit($timeoutms))) {
        write-host -f red "ERROR: timeout while installing: $exe"
        return 1
    }
}

function interactive {
    $noni = [Environment]::GetCommandLineArgs() | Where-Object{ $_ -like '-NonI*' }
    return ([Environment]::UserInteractive -and -not $noni)
}

function find_ustr ($name) {
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    $chld = Get-childitem $key | get-itemproperty | Where-Object { $_.DisplayName -match "$name" }
    if ($chld) {
        return $chld.uninstallstring
    }
    return $null
}

function ustr ($name){
    # uninstall with msiexec via registry uninstall string
    if (! ($ustr = (find_ustr $name))) {
        write-host -f red "failed to find uninstall string for: $name"
        return 1
    }
    if (! ($ustr -match 'msiexec')) {
        write-host -f red "uninstall string is not msiexec for: $name"
        return 1
    }
    $ustr = $ustr.replace('msiexec.exe', '', 'OrdinalIgnoreCase')
    $ustr = $ustr.replace('msiexec', '', 'OrdinalIgnoreCase')
    $ustr += ' /quiet'
    echo "uninstalling with msiexec and: $ustr"
    start-process msiexec -wait -NoNewWindow -argumentlist $ustr
}
