function network_up {
    $x = gcim Win32_NetworkAdapterConfiguration -filter DHCPEnabled=TRUE | where {$_.DefaultIPGateway -ne $null}
    return ($x | measure).count -gt 0
}

function network_wait (
    [int]$timeout = 300,
    [int]$pause = 10
) {
    $waited = 0
    while (-not (network_up)) {
        write-host 'NETWORK: waiting for network'
        start-sleep -s $pause

        waited += $pause
        if (waited -ge $timeout) {
            write-host "NETWORK: timed out after waiting for {$timeout} seconds"
            return $false
        }
    }
    return $true
}

function dl_retry (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$src,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$dst
) {
    write-host 'DL: start transfer'

    $done = $false
    while (-not $done) {
        try {
            iwr $src -OutFile $dst -useb
            $done = $true
        } catch {
            write-host 'NETWORK: caught error while downloading; waiting for network; retrying in 5s'
            rm_force $dst
            network_wait
        }
    }
}

function mntshare (
    [string][ValidateNotNullOrEmpty()] $pair
) {
    $split = $pair.split(' ')
    if (-not ($split[0] -and $split[1])) {
        write-host -f r 'mntshare: {pair} must include mount letter and network share path eg: {H: \\192.168.1.142\h}'
    }
    New-SmbMapping -ea 0 -LocalPath $split[0] -RemotePath $split[1] -persistent $true
}

function mntshares (
    [string[]] $pairs
) {
    foreach ($pair in $pairs) {
        mntshare $pair
    }
}

function mnt_nfs {
    mount -name Z -root \\192.168.1.142\mnt\q -psprovider filesystem -persist
    # note that remove-psdrive just straight up doesn't work. You have to use the ancient 'net use' cmd:
    net use Z: /delete
}

function smb_settings {
     $key = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters'
     setprop $key 'RequireSecuritySignature' 'DWORD' 0
     Set-SmbClientConfiguration -RequestCompression $true -Confirm:$false
}
