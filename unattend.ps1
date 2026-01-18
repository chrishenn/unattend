function glob_log ([string] $log) {
    if ($log) {
        Start-Transcript -Append $log
    }
}

function glob_req {
    $ppnames = (get-packageprovider).name
    if (-not ($ppnames -contains 'nuget')) {
        install-packageprovider nuget -force -ea 0
    }
    if (-not ($ppnames -contains 'powershellget')) {
        install-packageprovider powershellget -force -ea 0
    }
    if ($PSVersionTable.PSVersion.Major -le 5) {
        import-module Appx
    } else {
        import-module Appx -SkipEditionCheck
    }
    if (-not (get-module -ListAvailable chplib)) {
        install-module chplib -force -skippublishercheck
    }
    import-module chplib -force
}

function glob_lib ([string] $lib) {
    $libs = gci $lib -filter *.ps1
    foreach ($libf in $libs) {
        . $libf.fullname
    }
}

function glob_opt ([string] $repo, [string] $lib, [string] $log = '') {
    $cfgfile = "$repo\cfg.yml"
    $opt = @{
        'repo' = $repo;
        'log' = $log;
        'lib' = $lib;
        'cfgfile' = $cfgfile;
        'cfg' = cfg_yml $cfgfile;
        'playbook' = "$repo\playbook";
        'amecli' = "$repo\amecli\TrustedUninstaller.CLI.exe";
        'ameargs' = '';
        'sdio' = "$repo\lib\sdio.txt";
    }

    write-host ''
    write-host "global options: $($opt | format-table | out-string)"
    write-host ''
    return $opt
}

function glob_src ([string] $lib) {
    $erroractionpreference = 'Continue'
    $ConfirmPreference = 'None'
    $ProgressPreference = 'SilentlyContinue'

    . ${function:glob_req}
    . ${function:glob_lib} $lib
}

function tweak_security {
    write-host -f c 'tweak security'
    sec_uac
    sec_pwsh
    sec_defender
    sec_pw
    sec_ucpd
    sec_ie
    sec_spy
}

function tweak_network {
    write-host -f c 'tweak network'

    Get-NetConnectionProfile -InterfaceAlias 'Ethernet*' | Set-NetConnectionProfile -NetworkCategory 'Private'
    New-SmbShare -ea 0 -Name c -Path 'C:\' -FullAccess 'Everyone'
    [void](disable-windowsoptionalfeature -online -featurename WorkFolders-Client -norestart)

    net_smbsettings
    net_firewall
}

function acdc (
    $scheme,
    $cat,
    $id,
    $val
) {
    powercfg /SETACVALUEINDEX "$scheme" "$cat" "$id" $val
    powercfg /SETDCVALUEINDEX "$scheme" "$cat" "$id" $val
}

function tweak_power {
    write-host -f c 'tweak power'

    pwr_unhide
    pwr_throttling
    pwr_hybridsleep
    pwr_standby
    pwr_hybernate
    $pwrs = pwr_ultimate
    powercfg /SetActive $pwrs

    # lid close action {0: do nothing, 1: sleep, 2: hibernate, 3: shutdown}
    powercfg /SETACVALUEINDEX $pwrs '4f971e89-eebd-4455-a8de-9e59040e7347' '5ca83367-6e45-459f-a27b-476b1d01c936' 0
    powercfg /SETDCVALUEINDEX $pwrs '4f971e89-eebd-4455-a8de-9e59040e7347' '5ca83367-6e45-459f-a27b-476b1d01c936' 1

    # console lock
    acdc $pwrs SUB_VIDEO VIDEOCONLOCK 0
    # display off
    acdc $pwrs SUB_VIDEO VIDEOIDLE 0
    # usb suspend
    acdc $pwrs '2a737441-1930-4402-8d77-b2bebba308a3' '48e6b7a6-50f5-4782-a5d4-53bb8f07e226' 0
    # power button action {0: do nothing, 1: sleep, 2: hibernate, 3: shutdown}
    acdc $pwrs '4f971e89-eebd-4455-a8de-9e59040e7347' '7648efa3-dd9c-4e3e-b566-50f929386280' 3
    # sleep button action {0: do nothing, 1: sleep, 2: hibernate, 4: turn off display}
    acdc $pwrs '4f971e89-eebd-4455-a8de-9e59040e7347' '96996bc0-ad50-47ec-923b-6f41874dd9eb' 1
}

function drivers {
    write-host -f c 'drivers'

    $cput = hw_cpu
    if ($cput -eq [Cpu]::amd) {
        scoop install chris/amdchipset
    }
    if ($cput -eq [Cpu]::intel) {
        scoop install chris/intelhid
    }
    if (hw_intelapu) {
        scoop install chris/intelgfx
    }
    if (hw_amdapu) {
        scoop install chris/amdgfx
    }
    if (hw_intelwifi) {
        scoop install chris/intelwifi
        scoop install chris/intelbt
    }
    if (hw_nvgpu) {
        scoop install chris/nvgfx
        scoop install chris/nvapp
    }
}

function unattend1 ([hashtable] $opt) {
    write-host -f c 'main 1 start'
    net_wait
    tweak_security
    tweak_network
    tweak_power
    tweak_explorer
    tweak_graphics
    tweak_misc

    cfg_mntshare $opt.cfg
    cfg_scoop $opt.cfg
    sec_pwsh

    drivers
    update_all
    update_activate

    write-host -f green 'main 1 done'
    restart-computer -f
}

function unattend2 ([hashtable] $opt) {
    write-host -f c 'main 2 start'
    file_extensions
    file_reparsepoints
    file_clutter
    file_misc
    file_pins $opt.repo

    bloat_alienware
    bloat_edgeupdate
    bloat_killer
    bloat_waves
    bloat_gigabyte

    startup_rm @('SecurityHealth', 'Volt Driver Control Panel Autostart', 'waves')
    tray_hide 'universalaudio'

    pwr_dpst
    cfg_autologin $opt.cfgfile
    cfg_scoop_prv $opt.cfg $opt.cfgfile

    chezmoi init chrishenn --apply --force --promptDefaults
    & $opt.amecli $opt.playbook [string]$opt.ameargs

    write-host -f green 'main 2 done'
    restart-computer -f
}

function unattend ([int] $phase){
    $repo = $psscriptroot
    $lib = "$repo\lib"
    $log = "$repo\log_$phase.txt"
    glob_log $log
    . ${function:glob_src} $lib

    switch ($phase) {
        1 {unattend1 (glob_opt $repo $lib $log)}
        2 {unattend2 (glob_opt $repo $lib $log)}
        default {
            write-host -f red 'ERROR unattend: phase must be in {1,2}'
        }
    }
}
