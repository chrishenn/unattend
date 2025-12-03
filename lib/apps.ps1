function alienware {
    stop-process -name 'awccinstallationmanager' -force -ea 0
    stop-process -name 'aw.notificationutility' -force -ea 0

    rm_force 'C:\programdata\alienware'
    rm_force 'C:\program files\alienware'

    $dirs = get-childitem -directory 'C:\windows\system32\driverstore\filerepository' | where-object {$_.name -like "awcc_im_driver*"}
    foreach ($dir in $dirs) {
        get-childitem $dir -file | where-object {$_.name -match ".exe"} | remove-item -force -ea 0
    }
}

function edgeupdate {
#    stop-process -name 'MicrosoftEdgeUpdate' -force -ea 0
#    rm_force 'C:\Program Files (x86)\microsoft\edgeupdate'
#    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\edgeupdate'
#    SetProp $key 'UpdateDefault' 'DWORD' 0

    stop-process -force -ea 0 'MicrosoftEdgeUpdate'
    stop-process -force -ea 0 'edgeupdate'
    stop-process -force -ea 0 'edgeupdatem'

    stop-service -force -ea 0 edgeupdate
    remove-service -ea 0 edgeupdate
    stop-service -force -ea 0 edgeupdatem
    remove-service -ea 0 edgeupdatem
}

function killer {
    stop-service KAPSService -force -ea 0
    remove-service KAPSService -ea 0

    # killer startup task
    $tasks = get-scheduledtask | where-object {$_.taskname -match 'killer'}
    foreach ($task in $tasks) {
        unregister-scheduledtask $task.taskname -Confirm:$false
    }

    # killer control center
    $pkgs = get-appxPackage -AllUsers | where-object {$_.name -match 'killer'}
    foreach ($pkg in $pkgs) {
        remove-appxpackage $pkg -allusers
    }

    # killer services. drivers should be .inf files, but .exe's are not needed
    $dirs = get-childitem -directory 'C:\windows\system32\driverstore\filerepository' | where-object {$_.name -like "killer*"}
    foreach ($dir in $dirs) {
        get-childitem $dir -file | where-object {$_.name -match ".exe"} | remove-item -force -ea 0
    }

    # prog files
    rm -r -force -ea 0 "C:\windows\system32\drivers\rivetnetworks"
    rm -r -force -ea 0 "C:\programdata\rivetnetworks"
}

function waves {
    svc_rm 'WavesSysSvc'
    svc_rm 'WavesAudioService'

    rm -r -force -ea 0 "C:\Program Files\Waves"
    rm -r -force -ea 0 "C:\Program Files (x86)\Waves"
    rm -r -force -ea 0 "C:\ProgramData\Waves Audio"
    rm -r -force -ea 0 "C:\ProgramData\Waves"

    # this may be the only necessary step
    $path = "C:\Windows\System32\DriverStore\FileRepository"
    $wavesdirs = get-childitem $path -Directory | where-object {$_.name -like "*waves*"}
    foreach ($drdir in $wavesdirs) {
        pnputil /delete-driver $drdir /uninstall
    }
}

# function chipset {
    # todo: duplicate these to playbook svc.yml
    # todo: these names are just a guess
    # amd external events utilty
    # svc_rm 'AmdAppCompatSvc'
    # amd crash defender service
    # svc_rm 'AMD Crash Defender Service'
    # amd application compatibility service
    # svc_rm 'amd application compatibility service'

    # todo: duplicate the intel chipset svcs from playbook svc.yml
    # todo: I don't remember the names
    # playbook/Configuration/tasks/svc.yml
    # svc_rm 'Intel(R) Platform License Manager Service'
# }

function gigabyte {
    # gigabyte motherboard rootkit
    svc_rm 'gigabyteupdateservice'
}
