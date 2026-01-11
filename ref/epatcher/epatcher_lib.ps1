function epatcher_install {
    if (-not (is_admin)) {
        error "$app requires admin rights to $cmd"
        break
    }
    $proc = start-process "$dir\ep_setup.exe" -NoNewWindow -passthru
    if (-not $proc.waitforexit(10000)) {
        error 'Failed installing explorerpatcher due to timeout (10 seconds)'
        break
    }
    write-host ''
    write-host -f y 'WARNING: ExplorerPatcher must be UNINSTALLED from an INTERACTIVE shell'
    write-host -f green 'The ExplorerPatcher installer may have killed your desktop shell. This is normal.'
    write-host -f green 'Please reboot to complete the installation'
}

function epatcher_uninstall {
    if (-not (is_admin)) {
        error "$app requires admin rights to $cmd"
        break
    }
    function env_interactive {
        $noni = [Environment]::GetCommandLineArgs() | Where-Object{ $_ -like '-NonI*' }
        return ([Environment]::UserInteractive -and -not $noni)
    }
    if (-not (env_interactive)) {
        write-host ''
        write-host -f y 'ExplorerPatcher has no silent uninstaller; you must launch from an interactive shell'
        write-host -f y 'and click through the uninstall dialogs in order to uninstall.'
        error 'ExplorerPatcher: Uninstalling from noninteractive shell is not supported'
        break
    }
    $proc = start-process "$dir\ep_setup.exe" -NoNewWindow -passthru -a '/uninstall'
    if (-not $proc.waitforexit(10000)) {
        error 'Failed uninstalling explorerpatcher due to timeout (10 seconds)'
        break
    }
}
