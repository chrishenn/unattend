function bloat_alienware {
    stop-process -name 'awccinstallationmanager' -force -ea 0
    stop-process -name 'aw.notificationutility' -force -ea 0

    file_rmf 'C:\programdata\alienware'
    file_rmf 'C:\program files\alienware'

    $dirs = gci -directory 'C:\windows\system32\driverstore\filerepository' | ? {$_.name -like "awcc_im_driver*"}
    foreach ($dir in $dirs) {
        gci $dir.fullname -file | ? {$_.name -match ".exe"} | rm -force -ea 0
    }
}

function bloat_edgeupdate {
    # does this break webview2?

    stop-process -force -ea 0 -name 'MicrosoftEdgeUpdate'

    stop-process -force -ea 0 -name edgeupdate
    svc_rm edgeupdate

    stop-process -force -ea 0 -name edgeupdatem
    svc_rm edgeupdatem

    $names = '(MicrosoftEdgeUpdateTaskMachineCore|MicrosoftEdgeUpdateTaskMachineUA)'
    $tasks = get-scheduledtask | ? {$_.taskname -match $names}
    foreach ($task in $tasks) {
        [void](Disable-ScheduledTask $task)
    }

    # does this break webview2?
    # file_rmf 'C:\Program Files (x86)\microsoft\edgeupdate'
    # $key = 'HKLM:\SOFTWARE\Policies\Microsoft\edgeupdate'
    # rprop $key 'UpdateDefault' 'DWORD' 0
}

function bloat_killer {
    svc_rm KAPSService

    # killer startup task
    $tasks = get-scheduledtask | ? {$_.taskname -match 'killer'}
    foreach ($task in $tasks) {
        unregister-scheduledtask $task.taskname -Confirm:$false
    }

    # killer control center
    $pkgs = get-appxPackage -AllUsers | ? {$_.name -match 'killer'}
    foreach ($pkg in $pkgs) {
        remove-appxpackage $pkg -allusers
    }

    # killer services. drivers should be .inf files, but .exe's are not needed
    $dirs = gci -directory 'C:\windows\system32\driverstore\filerepository' | ? {$_.name -like "killer*"}
    foreach ($dir in $dirs) {
        gci $dir.fullname -file | ? {$_.name -match ".exe"} | rm -force -ea 0
    }

    # prog files
    rm -r -force -ea 0 "C:\windows\system32\drivers\rivetnetworks"
    rm -r -force -ea 0 "C:\programdata\rivetnetworks"
}

function bloat_waves {
    svc_rm WavesSysSvc
    svc_rm WavesAudioService

    rm -r -force -ea 0 "C:\Program Files\Waves"
    rm -r -force -ea 0 "C:\Program Files (x86)\Waves"
    rm -r -force -ea 0 "C:\ProgramData\Waves Audio"
    rm -r -force -ea 0 "C:\ProgramData\Waves"

    # this may be the only necessary step
    $path = 'C:\Windows\System32\DriverStore\FileRepository'
    $dirs = gci $path -Directory | ? {$_.name -like "*waves*"}
    foreach ($dir in $dirs) {
        pnputil /delete-driver $dir.fullname /uninstall
    }
}

function bloat_gigabyte {
    svc_rm gigabyteupdateservice
}
