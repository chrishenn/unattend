function dpst (
    [switch] $enable = $false,
    [switch] $status = $false
) {
    # usage:
    #   dpst -enable # enable dpst [default: false ("disable")]
    #   dpst -status # print dpst status and return

    $ftcname = "FeatureTestControl"
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
    $keys = Get-ChildItem -ea 0 "$key" | Where-Object {$_.Name -match '\\\d{4}$'}

    $ftc_path = ""
    foreach ($key in $keys) {
        if ($key.GetValue($ftcname, $null) -ne $null) {
            $ftc_path = $key.name
            break
        }
    }
    if (-not $ftc_path) {
        Write-Error "Cannot locate ftc in registry"
        return 1
    }

    $ftc = (Get-Item "Registry::${ftc_path}").GetValue($ftcname)
    $bitmask = 1 -shl 4
    $enabled = -not [bool]($ftc -band $bitmask)
    $enabled_str = if ($enabled) {"enabled"} else {"disabled"}

    if ($status) {
        Write-host -f c "DPST is: $enabled_str"
        return
    }

    $ftc_new = 0
    if ($enable -and -not $enabled) {
        Write-host -f c "DPST is disabled; enabling"
        $ftc_new = $ftc -band (-bnot $bitmask)
    } elseif (-not $enable -and $enabled) {
        Write-host -f c "DPST is enabled; disabling"
        $ftc_new = $ftc -bor $bitmask
    } else {
        Write-host -f green "DPST unchanged | requested {enabled: $enabled} | currently {enabled: $enabled}"
        return
    }
    setprop "Registry::$ftc_path" "$ftcname" "DWORD" $ftc_new
    Write-host -f green "Set DPST. Reboot is required for changes to take effect"
}
