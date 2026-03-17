function lmcu (
    $stem,
    $prop,
    $type,
    $val
) {
    rprop "HKLM:$stem" "$prop" "$type" "$val"
    rprop "HKCU:$stem" "$prop" "$type" "$val"
}

function hideprop (
    $key
) {
    rprop $key 'ThisPCPolicy' 'String' 'Hide'
}

function tweak_explorer {
    write-host -f c 'tweak explorer'

    # hide from file explorer
    $ex = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'
    $fd = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions'
    hideprop "$ex\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag"
    hideprop "$fd\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"
    hideprop "$ex\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag"
    hideprop "$fd\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}"
    hideprop "$ex\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag"
    hideprop "$fd\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}"
    hideprop "$ex\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag"
    hideprop "$fd\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"
    hideprop "$ex\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag"
    hideprop "$fd\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}"
    hideprop "$ex\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag"
    hideprop "$fd\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"
    rm -r -ea 0 "$ex\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}"
    hideprop "$ex\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag"
    hideprop "$fd\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag"

    # hide gallery, home from file explorer
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}'
    rprop $key '(Default)' 'String' 'Gallery'
    rprop $key 'HiddenByDefault' 'DWORD' 1
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\NonEnum'
    rprop $key '{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}' 'DWORD' 1
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}'
    rprop $key '(Default)' 'String' 'CLSID_MSGraphHomeFolder'
    rprop $key 'HiddenByDefault' 'DWORD' 1

    # explorer tweaks
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
    rprop $key 'NoDesktop' 'DWORD' 1
    rprop $key 'NoDriveTypeAutoRun' 'DWORD' 0x000000FF

    $key = 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem'
    rprop $key 'LongPathsEnabled' 'DWORD' 1
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState'
    rprop $key 'FullPath' 'DWORD' 1

    # icon cache size
    rprop $ex 'MaxCachedIcons' 'String' 8192
}

function tweak_graphics {
    write-host -f c 'tweak graphics'
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'
    rprop "$key\AnimateMinMax" 'DefaultValue' 'DWORD' 0
    rprop "$key\ComboBoxAnimation" 'DefaultValue' 'DWORD' 0
    rprop "$key\ControlAnimations" 'DefaultValue' 'DWORD' 0
    rprop "$key\CursorShadow" 'DefaultValue' 'DWORD' 1
    rprop "$key\DragFullWindows" 'DefaultValue' 'DWORD' 1
    rprop "$key\DropShadow" 'DefaultValue' 'DWORD' 1
    rprop "$key\DWMAeroPeekEnabled" 'DefaultValue' 'DWORD' 0
    rprop "$key\DWMSaveThumbnailEnabled" 'DefaultValue' 'DWORD' 0
    rprop "$key\FontSmoothing" 'DefaultValue' 'DWORD' 1
    rprop "$key\ListBoxSmoothScrolling" 'DefaultValue' 'DWORD' 0
    rprop "$key\ListviewAlphaSelect" 'DefaultValue' 'DWORD' 1
    rprop "$key\ListviewShadow" 'DefaultValue' 'DWORD' 0
    rprop "$key\MenuAnimation" 'DefaultValue' 'DWORD' 0
    rprop "$key\SelectionFade" 'DefaultValue' 'DWORD' 0
    rprop "$key\TaskbarAnimations" 'DefaultValue' 'DWORD' 0
    rprop "$key\ThumbnailsOrIcon" 'DefaultValue' 'DWORD' 1
    rprop "$key\TooltipAnimation" 'DefaultValue' 'DWORD' 0
}

function tweak_misc {
    write-host -f c 'tweak misc'

    # notifications
    $stem = '\SOFTWARE\Policies\Microsoft\Windows\Explorer'
    lmcu $stem 'DisableNotificationCenter' 'DWORD' 1
    lmcu $stem 'TurnOffWindowsCopilot' 'DWORD' 1
    $stem = '\Software\Microsoft\Windows\CurrentVersion\PushNotifications'
    lmcu $stem 'ToastEnabled' 'DWORD' 0
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications'
    rprop $key 'DisableNotifications' 'DWORD' 1

    # ??
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
    rprop $key 'NetworkThrottlingIndex' 'DWORD' 0xffffffff
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Control'
    rprop $key 'WaitToKillServiceTimeout' 'String' '2000'

    # ??
    $key = 'HKCU:\Software\Classes\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs'
    rprop $key '(default)' 'String' '{64bc32b5-4eec-4de7-972d-bd8bd0324537}'
    $key = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
    rprop $key '(default)' 'String' ''

    # system tray
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray'
    rprop $key 'HideSystray' 'DWORD' 1
    $key = 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify'
    rprop $key 'SystemTrayChevronVisibility' 'DWORD' 0
    $key = 'HKCU:\Control Panel\Bluetooth'
    rprop $key 'Notification Area Icon' 'DWORD' 0

    # offline files, settings sync
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetCache'
    rprop $key 'Enabled' 'DWORD' 0
    $key = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Experience\AllowSyncMySettings'
    rprop $key 'value' 'DWORD' 0
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'
    rprop $key 'DisableSettingSync' 'DWORD' 2
    rprop $key 'DisableSettingSyncUserOverride' 'DWORD' 1
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
    rprop $key 'AllowAppSync' 'DWORD' 0
    $key = 'HKCU:\Software\Microsoft\Edge'
    rprop $key 'Sync' 'DWORD' 0

    # audio ducking
    $key = 'HKCU:\Software\Microsoft\Multimedia\Audio'
    rprop $key 'UserDuckingPreference' 'DWORD' 3

    # dark theme
    $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    rprop $key 'AppsUseLightTheme' 'DWORD' 0
    rprop $key 'SystemUsesLightTheme' 'DWORD' 0
    rprop $key 'ColorPrevalence' 'DWORD' 0
    rprop $key 'EnableTransparency' 'DWORD' 1
    # "automatically pick an accent color from my background"
    rprop 'HKCU:\Control Panel\Desktop' 'AutoColorization' 'DWORD' 1

    # key repeat times. takes effect after logout
    $key = 'HKCU:\Control Panel\Accessibility\Keyboard Response'
#    rprop $key 'AutoRepeatDelay' 'String' 150          # default: 1000
#    rprop $key 'AutoRepeatRate' 'String' 6             # default: 500
#    rprop $key 'BounceTime' 'String' 0                  # default: 0
#    rprop $key 'DelayBeforeAcceptance' 'String' 0      # default: 1000
#    rprop $key 'Flags' 'String' 27                     # default: 126

    rprop $key 'AutoRepeatDelay' 'String' 1000          # default: 1000
    rprop $key 'AutoRepeatRate' 'String' 500            # default: 500
    rprop $key 'BounceTime' 'String' 0                  # default: 0
    rprop $key 'DelayBeforeAcceptance' 'String' 1000    # default: 1000
    rprop $key 'Flags' 'String' 126                     # default: 126

    # disable mouse accel
    $key = 'HKCU:\Control Panel\Mouse'
    rprop $key 'MouseSpeed' 'String' 0
    rprop $key 'MouseThreshold1' 'String' 0
    rprop $key 'MouseThreshold2' 'String' 0
}
