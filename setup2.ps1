param(
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $user,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $pass
)

function setup2 {
    write-host -f c "setup2 begin"

    file_extensions
    file_reparsepoints
    file_clutter
    file_misc
    file_pins $psscriptroot

    bloat_alienware
    bloat_edgeupdate
    bloat_killer
    bloat_waves
    bloat_gigabyte

    startup_rm @('SecurityHealth', 'Volt Driver Control Panel Autostart', 'waves')
    tray_hide 'universalaudio'

    autologin $user $pass
    pwr_dpst
    cfg_scoop_prv $cfg
    chezmoi init chrishenn --apply --force --promptDefaults
    & "$psscriptroot\amecli\TrustedUninstaller.CLI.exe" "$psscriptroot\playbook" ''
}

. "$psscriptroot\setup_init.ps1" "$psscriptroot\log2.txt"
setup2
write-host -f green "setup2 done"
restart-computer -f
