param(
    [string][ValidateNotNullOrEmpty()] $user,
    [string][ValidateNotNullOrEmpty()] $pass
)

$erroractionpreference = 'Continue'
$ConfirmPreference = 'None'
$repo = $PSScriptRoot
Start-Transcript -Append "$repo\log2.txt"
(get-childitem "$repo\lib\*.ps1").foreach({. $_.FullName})
$cfg = cfg_yml "$repo\cfg.yml"


function file_misc {
    # installer files packaged into iso/$OEM$ are duplicated in these places
    rm_force 'C:\windows\configsetroot\sources\$OEM$'
    rm_force 'C:\windows\serviceprofiles\localservice\unattend'
    rm_force 'C:\windows\serviceprofiles\networkservice\unattend'
    rm_force 'C:\users\Default\unattend'

    # empty default folder
    rm_force "$env:appdata\microsoft\windows\start menu\programs\maintenance"
    rm_force "$env:userprofile\appdata\roaming\microsoft\windows\start menu\programs\maintenance"

    # not sure why this was there
    rm_force 'C:\programdata\Ame'
    rm_force 'C:\Windows\SystemApps\Microsoft.MicrosoftEdgeDevToolsClient_*'
}

function scoop_boot_private (
    [Hashtable] $cfg
) {
    if (-not $cfg.containskey("scoop_private")) {
        write-host -f y "WARN (scoop_private): not key scoop_private in hashtable param 'cfg'"
        return
    }
    if (-not (scoop config gh_token)) {
        if (-not (installed op)) {
            write-host -f r "ERROR (scoop_private): scoop gh_token not set and op is not installed"
            return
        }
        if (-not $env:OP_SERVICE_ACCOUNT_TOKEN) {
            write-host -f r "ERROR (scoop_private): scoop gh_token not set and OP_SERVICE_ACCOUNT_TOKEN not set"
            return
        }
        scoop config gh_token (op read "op://homelab/github/credential")
        if (-not (scoop config gh_token)) {
            write-host -f r "ERROR (scoop_private): tried to set scoop gh_token but it's still empty"
            return
        }
    }
    scoop_apps $cfg.scoop_private
}

function setup2 {
    write-host -f c "setup2 begin"

    file_misc
    file_reparsepoints
    file_clutter

    file_extensions
    file_pins

    alienware
    edgeupdate
    killer
    waves
    gigabyte

    dpst
    startups_rm @('SecurityHealth', 'Volt Driver Control Panel Autostart', 'waves')
    trays_hide @('universalaudio')

    scoop_boot_private $cfg
    chezmoi init chrishenn --apply --force
    & "$repo\amecli\TrustedUninstaller.CLI.exe" "$repo\playbook" ''

    write-host -f green "setup2 done"
}

if ($PSVersionTable.PSVersion.Major -ge 6) {
    Import-Module Appx -UseWindowsPowershell 3>$null
}
autologin $user $pass
setup2
restart-computer -f
