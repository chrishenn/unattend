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
    disable-windowsoptionalfeature -online -featurename WorkFolders-Client

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
    # todo: detect motherboard and install driver package; possibly use snappy sdio
    # todo: handle driver quirks

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

function setup {
    write-host -f c 'setup start'
    net_wait
    tweak_security
    tweak_network
    tweak_power
    tweak_explorer
    tweak_graphics
    tweak_misc

    cfg_mntshare
    cfg_scoop $cfg
    sec_pwsh

    drivers
    update_all
    update_activate
}

. "$psscriptroot\setup_init.ps1" "$psscriptroot\log.txt"
setup
write-host -f green 'setup done'
restart-computer -f
