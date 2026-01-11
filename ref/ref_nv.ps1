function nvtelemetry {
    # uninstalling NvTelemetry completely uninstalls nvapp - hard dependency enforced by nvidia's packaging infra

    # possibly blocking these with autoruns would work
    # $todel = "C:\program files (x86)\NVIDIA Corporation\NvTelemetry\*.dll"
    # $todel = "C:\program files\NVIDIA Corporation\NvTelemetry\*.dll"

    $dll = 'C:\Program Files\NVIDIA Corporation\Installer2\InstallerCore\NVI2.DLL'
    if (test-path $dll) {
        $argsl = """$dll"",UninstallPackage NvTelemetryContainer -silent"
        Start-Process -wait RunDll32 -a $argsl

        $argsl = """$dll"",UninstallPackage NvTelemetry -silent"
        Start-Process -wait RunDll32 -a $argsl
    }

    # outdated, I think
    $tasks = get-scheduledtask | where-object {$_.taskname -match '(NvTmRep|NvTmRepOnLogon|NvTmMon)'}
    foreach ($task in $tasks) {
        Disable-ScheduledTask $task
    }

    setprop 'HKLM:\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client' 'OptInOrOutPreference' 'DWORD' 0
    setprop 'HKLM:\SOFTWARE\NVIDIA Corporation\Global\FTS' 'EnableRID44231' 'DWORD' 0
    setprop 'HKLM:\SOFTWARE\NVIDIA Corporation\Global\FTS' 'EnableRID64640' 'DWORD' 0
    setprop 'HKLM:\SOFTWARE\NVIDIA Corporation\Global\FTS' 'EnableRID66610' 'DWORD' 0
    setprop 'HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\Startup' 'SendTelemetryData' 'DWORD' 0
}

function nvtray {
    write-host 'NVIDIA TRAY: hide nv tray icon'
    # https://www.elevenforum.com/t/fix-for-nvidia-taskbar-icon-missing.1853/
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm\NVTray'
    setprop $key 'StartOnLogin' 'DWORD' 0
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak'
    setprop $key 'DisableStoreNvCplNotifications' 'DWORD' 1

    if (get-process explorer -ea 0) {
        stop-process -name explorer -force
    }
}

function nvcontainer {
    # required for nvcontrol panel, but safe to disable and use nvapp instead
    svc_disable 'NVDisplay.ContainerLocalSystem'
}