enum Cpu {
    unknown = -1
    amd = 0
    intel = 1
}

function cpu {
    if (get-pnpdevice -class processor -instanceid 'ACPI\AUTHENTICAMD*' -ea 0) {
        return [Cpu]::amd
    }
    if (get-pnpdevice -class processor -instanceid 'ACPI\GENUINEINTEL*' -ea 0) {
        return [Cpu]::intel
    }
    return [Cpu]::unknown
}

# Note: the pnpdevice class is only assigned when a driver is assigned to the device.
#   In the case of these igpu's, I'm assuming that the MS basic display driver will be correctly assigned by default.
# Realistically, you need to tabulate all the device instanceids that you care about and match them
#    to robustly detect your devices of interest here (possibly vendorid and any HardwareID, CompatibleID for a device)
# Doing dumb string regex quickly also means compiling a native binary ... later.
# Haxx ahead for now

function nvidia_gpu {
    return get-pnpdevice -present -class display | where-object {$_.manufacturer -eq "nvidia"}
#    return gcim Win32_VideoController | Where-Object {$_.VideoProcessor -match "nvidia"}
}

function nv_wait (
    [int] $timeout = 120,
    [int] $pause = 10
) {
    $waited = 0
    while (-not ($gpu = nvidia_gpu)) {
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

function amd_apu {
    # assumes that the MS basic display driver will be correctly assigned by default
    $venstr = "ven_1002"
    return Get-pnpdevice -present -class display | where-object {$_.instanceid -match $venstr}
}

function intel_apu {
    # assumes that the MS basic display driver will be correctly assigned by default
    $venstr = "ven_8086"
    return Get-pnpdevice -present -class display | where-object {$_.instanceid -match $venstr}
}

function intel_wifi {
    # according to https://www.devicekb.com/hardware/pci-vendors/ven_8086-dev_272b
    # PCI\VEN_8086&DEV_272B is recognized as Intel Wi-Fi 7 AX1775*/AX1790*/BE20*/BE401/BE1750* 2x2
    $devstr = 'PCI\\VEN_8086&DEV_272B'
    return Get-pnpdevice -present | where-object {$_.instanceid -match $devstr}
}
