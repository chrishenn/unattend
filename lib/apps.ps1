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

function gigabyte {
    svc_rm 'gigabyteupdateservice'
}
