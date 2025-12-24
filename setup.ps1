$erroractionpreference = 'Continue'
$ConfirmPreference = 'None'
$repo = $PSScriptRoot
Start-Transcript -Append "$repo\log.txt"
(get-childitem "$repo\lib\*.ps1").foreach({. $_.FullName})

# required for install-module
Install-packageprovider nuget -force
install-packageprovider powershellget -force
$cfg = cfg_yml "$repo\cfg.yml"

function hide ($key) {
    setprop $key 'ThisPCPolicy' 'String' 'Hide'
}

function lmcu ($stem, $prop, $type, $val) {
    setprop "HKLM:$stem" "$prop" "$type" "$val"
    setprop "HKCU:$stem" "$prop" "$type" "$val"
}

function acdc ($scheme, $cat, $id, $val) {
    powercfg /SETACVALUEINDEX "$scheme" "$cat" "$id" $val
    powercfg /SETDCVALUEINDEX "$scheme" "$cat" "$id" $val
}

function network {
    write-host -f c 'network'

    # set ethernet* networks to private
    Get-NetConnectionProfile -InterfaceAlias 'Ethernet*' | Set-NetConnectionProfile -NetworkCategory 'Private'

    # set firewall permissive (but don't disable; needed for ame blocking)
    Set-NetFirewallProfile -Profile Domain, Public, Private -DefaultInboundAction Allow
    Set-NetFirewallProfile -Profile Domain, Public, Private -DefaultOutboundAction Allow

    # smb
    Set-SmbServerConfiguration -EnableMultiChannel $true -force
    Set-SmbClientConfiguration -EnableMultiChannel $true -force

    # disable work folders
    disable-windowsoptionalfeature -online -featurename WorkFolders-Client

    # share the C:\ drive
    New-SmbShare -ea 0 -Name c -Path "C:\" -FullAccess 'Everyone'
}

function power {
    write-host -f c 'power'

    $out = powercfg /DuplicateScheme 'e9a42b02-d5df-448d-aa00-03f14749eb61'
    $pwrs = if ($out -match '\s([a-f0-9-]{36})\s') {
        powercfg /SetActive $Matches[1]
        $Matches[1]
    } else {
        write-host 'Could not enable Ultimate Performance power scheme.'
        'SCHEME_CURRENT'
    }

    # lid close action {0: do nothing, 1: sleep, 2: hibernate, 3: shutdown}
    powercfg /SETACVALUEINDEX $pwrs '4f971e89-eebd-4455-a8de-9e59040e7347' '5ca83367-6e45-459f-a27b-476b1d01c936' 0
    powercfg /SETDCVALUEINDEX $pwrs '4f971e89-eebd-4455-a8de-9e59040e7347' '5ca83367-6e45-459f-a27b-476b1d01c936' 1

    # hybrid sleep
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\94ac6d29-73ce-41a6-809f-6363ba21b47e'
    setprop $key 'ACSettingIndex' 'DWORD' 0
    setprop $key 'DCSettingIndex' 'DWORD' 0

    # turn off hybernation
    powercfg /h off

    # require sign-on on wake
    $key = 'HKCU:\Control Panel\Desktop'
    setprop $key 'DelayLockInterval' 'DWORD' 0xffffffff

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

function tweak {
    write-host -f c 'tweak'

    # hide from explorer
    $ex = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'
    $fd = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions'
    hide "$ex\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag"
    hide "$fd\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"
    hide "$ex\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag"
    hide "$fd\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}"
    hide "$ex\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag"
    hide "$fd\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}"
    hide "$ex\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag"
    hide "$fd\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"
    hide "$ex\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag"
    hide "$fd\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}"
    hide "$ex\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag"
    hide "$fd\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}"
    hide "$ex\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag"
    hide "$fd\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag"

    # icon cache size
    setprop $ex 'MaxCachedIcons' 'String' 8192

    # explorer
    $stem = '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    lmcu $stem 'DisablePreviewDesktop' 'DWORD' 1
    lmcu $stem 'HideFileExt' 'DWORD' 0
    lmcu $stem 'ExtendedUIHoverTime' 'DWord' 100000
    lmcu $stem 'NavPaneShowAllFolders' 'DWord' 0
    lmcu $stem 'Hidden' 'DWORD' 1 # {1: show hidden files, 2: don't show hidden files}
    lmcu $stem 'ShowSuperHidden' 'DWORD' 1
    lmcu $stem 'ShowStatusBar' 'DWORD' 0
    lmcu $stem 'TaskbarSmallIcons' 'DWORD' 1
    lmcu $stem 'ShowTaskViewButton' 'DWORD' 0
    lmcu $stem 'TaskbarAnimations' 'DWORD' 0
    lmcu $stem 'SnapAssist' 'DWORD' 0
    lmcu $stem 'EnableSnapAssistFlyout' 'DWORD' 0
    lmcu $stem 'EnableSnapBar' 'DWORD' 0
    lmcu $stem 'EnableTaskGroups' 'DWORD' 0
    lmcu $stem 'TaskbarFlashing' 'DWORD' 0
    lmcu $stem 'DisallowShaking' 'DWord' 1
    lmcu $stem 'TaskbarSd' 'DWord' 0
    lmcu $stem 'LaunchTo' 'DWORD' 1 # {1: thispc, 2: quick access, 3: undocumented (downloads?)}
    lmcu $stem 'Start_TrackDocs' 'DWORD' 0
    lmcu $stem 'StartShownOnUpgrade' 'DWORD' 1

    $stem = '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'
    lmcu $stem 'EnableAutoTray' 'DWORD' 0
    lmcu $stem 'ShowFrequent' 'DWORD' 0
    lmcu $stem 'ShowRecent' 'DWORD' 0

    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    setprop $key 'NoDesktop' 'DWORD' 1
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    setprop $key 'NoDriveTypeAutoRun' 'DWORD' 0x000000FF
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
    setprop $key 'DisableLockWorkstation' 'DWORD' 1
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
    setprop $key 'NetworkThrottlingIndex' 'DWORD' 0xffffffff
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Control'
    setprop $key 'WaitToKillServiceTimeout' 'String' '2000'
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling'
    setprop $key 'PowerThrottlingOff' 'DWORD' 1
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem'
    setprop $key 'LongPathsEnabled' 'DWORD' 1
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
    setprop $key 'AllowDevelopmentWithoutDevLicense' 'DWORD' 1
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Sudo'
    setprop $key 'Enabled' 'DWORD' 1
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState'
    setprop $key 'FullPath' 'DWORD' 1
    $key = 'HKCU:\Control Panel\Bluetooth'
    setprop $key 'Notification Area Icon' 'DWORD' 0
    $key = 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify'
    setprop $key 'SystemTrayChevronVisibility' 'DWORD' 0
    $key = 'HKCU:\Software\Classes\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs'
    setprop $key '(default)' 'String' '{64bc32b5-4eec-4de7-972d-bd8bd0324537}'
    $key = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
    setprop $key '(default)' 'String' ''

    # gallery, home (file explorer)
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}'
    setprop $key '(Default)' 'String' 'Gallery'
    setprop $key 'HiddenByDefault' 'DWORD' 1
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\NonEnum'
    setprop $key '{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}' 'DWORD' 1
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}'
    setprop $key '(Default)' 'String' 'CLSID_MSGraphHomeFolder'
    setprop $key 'HiddenByDefault' 'DWORD' 1

    # notifications
    $stem = '\SOFTWARE\Policies\Microsoft\Windows\Explorer'
    lmcu $stem 'DisableNotificationCenter' 'DWORD' 1
    lmcu $stem 'TurnOffWindowsCopilot' 'DWORD' 1
    $stem = '\Software\Microsoft\Windows\CurrentVersion\PushNotifications'
    lmcu $stem 'ToastEnabled' 'DWORD' 0
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications'
    setprop $key 'DisableNotifications' 'DWORD' 1

    # tray
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray'
    setprop $key 'HideSystray' 'DWORD' 1

    # offline files, settings sync
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetCache'
    setprop $key 'Enabled' 'DWORD' 0
    $key = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Experience\AllowSyncMySettings'
    setprop $key 'value' 'DWORD' 0
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'
    setprop $key 'DisableSettingSync' 'DWORD' 2
    setprop $key 'DisableSettingSyncUserOverride' 'DWORD' 1
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
    setprop $key 'AllowAppSync' 'DWORD' 0
    $key = 'HKCU:\Software\Microsoft\Edge'
    setprop $key 'Sync' 'DWORD' 0

    # audio ducking
    $key = 'HKCU:\Software\Microsoft\Multimedia\Audio'
    setprop $key 'UserDuckingPreference' 'DWORD' 3

    # dark theme
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    setprop $key 'AppsUseLightTheme' 'DWORD' 0
    setprop $key 'SystemUsesLightTheme' 'DWORD' 0
    setprop $key 'ColorPrevalence' 'DWORD' 0
    setprop $key 'EnableTransparency' 'DWORD' 1
    # 'automatically pick an accent color from my background'
    setprop 'HKCU:\Control Panel\Desktop' 'AutoColorization' 'DWORD' 1

    # key repeat times. takes effect after logout
    # to enable key debounce ('filter keys'), set flags=126, bouncetime in ms
    $key = 'HKCU:\Control Panel\Accessibility\Keyboard Response'
    setprop $key 'AutoRepeatDelay' 'DWORD' 150          # default: 1000 [under 150 is said to cause problems]
    setprop $key 'AutoRepeatRate' 'DWORD' 10            # default: 500  [repeat period (not rate) in ms]
    setprop $key 'DelayBeforeAcceptance' 'DWORD' 0      # default: 1000 [setting to 150 or 200 may resolve problems]
    setprop $key 'Flags' 'DWORD' 27                     # default: 126  [disables filter key icon, which causes problems]
    setprop $key 'BounceTime' 'DWORD' 0                 # default: 126

    $key = 'HKCU:\Control Panel\Keyboard'
    setprop $key 'KeyboardDelay' 'DWORD' 0
    setprop $key 'KeyboardSpeed' 'DWORD' 31

    # disable mouse accel
    $key = 'HKCU:\Control Panel\Mouse'
    setprop $key 'MouseSpeed' 'String' 0
    setprop $key 'MouseThreshold1' 'String' 0
    setprop $key 'MouseThreshold2' 'String' 0
}

function tweak_graphics {
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'
    setprop "$key\AnimateMinMax" 'DefaultValue' 'DWORD' 0
    setprop "$key\ComboBoxAnimation" 'DefaultValue' 'DWORD' 0
    setprop "$key\ControlAnimations" 'DefaultValue' 'DWORD' 0
    setprop "$key\CursorShadow" 'DefaultValue' 'DWORD' 1
    setprop "$key\DragFullWindows" 'DefaultValue' 'DWORD' 1
    setprop "$key\DropShadow" 'DefaultValue' 'DWORD' 1
    setprop "$key\DWMAeroPeekEnabled" 'DefaultValue' 'DWORD' 0
    setprop "$key\DWMSaveThumbnailEnabled" 'DefaultValue' 'DWORD' 0
    setprop "$key\FontSmoothing" 'DefaultValue' 'DWORD' 1
    setprop "$key\ListBoxSmoothScrolling" 'DefaultValue' 'DWORD' 0
    setprop "$key\ListviewAlphaSelect" 'DefaultValue' 'DWORD' 1
    setprop "$key\ListviewShadow" 'DefaultValue' 'DWORD' 0
    setprop "$key\MenuAnimation" 'DefaultValue' 'DWORD' 0
    setprop "$key\SelectionFade" 'DefaultValue' 'DWORD' 0
    setprop "$key\TaskbarAnimations" 'DefaultValue' 'DWORD' 0
    setprop "$key\ThumbnailsOrIcon" 'DefaultValue' 'DWORD' 1
    setprop "$key\TooltipAnimation" 'DefaultValue' 'DWORD' 0
}

function security {
    write-host -f c 'security'

    # script execution
    Set-ExecutionPolicy -force -scope LocalMachine -ExecutionPolicy bypass
    Set-ExecutionPolicy -force -scope currentuser -ExecutionPolicy bypass
    if (installed pwsh) {
        pwsh -c '& {Set-ExecutionPolicy -force -scope localmachine -ExecutionPolicy bypass}'
        pwsh -c '& {Set-ExecutionPolicy -force -scope currentuser -ExecutionPolicy bypass}'
    }
    if (installed powershell) {
        powershell -c '& {Set-ExecutionPolicy -force -scope LocalMachine -ExecutionPolicy bypass}'
        powershell -c '& {Set-ExecutionPolicy -force -scope currentuser -ExecutionPolicy bypass}'
    }

    # disable password expiry
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordPolicy'
    setprop $key 'DisablePasswordExpiration' 'DWORD' 1

    # UAC
    $key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
    setprop $key 'ConsentPromptBehaviorAdmin' 'DWORD' 0

    # IE security
    $key = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'
    setprop $key 'IsInstalled' 'DWORD' 0
    $key = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}'
    setprop $key 'IsInstalled' 'DWORD' 0

    # security (redundant with unattend, AME)
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'
    setprop $key 'DisableAntiVirus' 'DWORD' 1
    setprop $key 'DisableBehaviorMonitoring' 'DWORD' 1
    setprop $key 'DisableOnAccessDetection' 'DWord' 1
    setprop $key 'DisableScanOnRealtimeEnable' 'DWord' 1
    setprop $key 'DisableAntiSpyware' 'DWord' 1
    setprop $key 'DisableSpecialRunningModes' 'DWORD' 1
    setprop $key 'DisableTamperProtection' 'DWORD' 1
    setprop $key 'DisableAntiSpywareDefinitionUpdate' 'DWORD' 1
    setprop $key 'AllowCloudProtection' 'DWORD' 0
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection'
    setprop $key 'DisableRealtimeMonitoring' 'DWORD' 1
    setprop $key 'DisableBehaviorMonitoring' 'DWord' 1
    setprop $key 'DisableOnAccessProtection' 'DWord' 1
    setprop $key 'DisableScanOnRealtimeEnable' 'DWord' 1
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    setprop $key 'EnableSmartScreen' 'DWord' 0
    setprop $key 'EnableActivityFeed' 'DWord' 0
    setprop $key 'PublishUserActivities' 'DWord' 0
    setprop $key 'UploadUserActivities' 'DWord' 0
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet'
    setprop $key 'DisableBlockAtFirstSeen' 'DWORD' 1
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting'
    setprop $key 'DisableEnhancedNotifications' 'DWORD' 1
    setprop $key 'DisableGenericReports' 'DWORD' 1
    setprop $key 'DisableGenericRemediation' 'DWORD' 1

    # ucpd driver (requires restart to take effect)
    [void](Disable-ScheduledTask '\Microsoft\Windows\AppxDeploymentClient\UCPD velocity')
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Services\UCPD'
    setprop $key 'Start' 'DWORD' 4
}

function update {
    write-host -f c 'update'
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-Module PSWindowsUpdate -force
    }
    Import-Module PSWindowsUpdate
    Get-WindowsUpdate -acceptall -MicrosoftUpdate -NotTitle OneDrive -Category Driver -Install -IgnoreReboot
    Install-WindowsUpdate -NotTitle OneDrive -AcceptAll -IgnoreReboot
}

function activate {
    write-host -f c 'activate'
    try {
        iex "& {$(irm https://get.activated.win)} /HWID"
    } catch {
        write-host -f r 'SETUP: HWID activate failed'
    }
}

function setup {
    write-host -f c 'setup start'

    security
    network_wait
    network
    if ($cfg.containskey('shares')) {
        mntshares $cfg.shares
    }
    pwr_unhide
    power
    tweak
    tweak_graphics

    scoop_boot $cfg

    $cput = cpu
    if ($cput -eq [Cpu]::amd) {
        scoop install chris/amdchipset
    }
    if ($cput -eq [Cpu]::intel) {
        scoop install chris/intelserialio
    }
    if (nvidia_gpu) {
        scoop install chris/nvgfx
    if (nv_vc) {
        scoop install chris/nvdriver
        scoop install chris/nvapp
    }
    if (intel_apu) {
        scoop install chris/intelgfx
    }
    if (amd_apu) {
        scoop install chris/amdgfx
    }
    if (intel_wifi) {
        scoop install chris/intelwifi
        scoop install chris/intelbt
    }
    if (intel_apu) {
        scoop install chris/intelgfx
    }
    if (amd_apu) {
        scoop install chris/amdgfx
    }
    if (intel_wifi) {
        scoop install chris/intelwifi
        scoop install chris/intelbt
    }
    # todo: detect motherboard and (host and) install a driver package. make sure to deduplicate with scoops above

    update
    activate

    write-host -f green 'setup done'
}

setup
restart-computer -f
