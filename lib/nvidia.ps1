function nv_vc {
    return Get-ciminstance Win32_VideoController | Where-Object {
        $_.Name -match "NVIDIA" -or $_.VideoProcessor -match "NVIDIA"
    }
}

function nv_wait (
    [int] $timeout = 120,
    [int] $pause = 10
) {
    $waited = 0
    while (-not ($gpu = nv_vc)) {
        write-host "nv_wait: waiting for nv_gpu with timeout: $timeout seconds"
        start-sleep -s $pause

        $waited += $pause
        if ($waited -ge $timeout) {
            write-host "nv_wait: exiting after waiting for more than timeout: $timeout seconds"
            return $null
        }
    }
    return $gpu
}
