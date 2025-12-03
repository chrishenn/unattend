<#
ancient notes
$key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings'
Export all under this key, make a backup, find and replace all "Attributes"=dword:00000001 with "Attributes"=dword:00000002

Some settings (like Intel Graphics Settings) don't have an "Attributes" DWord, so the find-and-replace will not enable them in the menu.
Go to the key for that option and add an "Attributes"=dword:00000002 to the reg key for the option.
This will not work for a key corresponding to a GROUP of options.

However, for some reason the entire "video settings" subgroup just refuses to show up in the power menu (it looks like
they're mostly redundant with other options). I don't know how to enable the group of settings in the menu, so I can use
powercfg from cmd to set options individually.

In the registry a key with friendly name "Enable Adaptive Brightness".
HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\7516b95f-f776-4464-8c53-06167f40cc99\FBD9AA66-9553-4097-BA44-ED6E9D65EAB8

List the GUID of the installed power profiles with powercfg /l. The active power profile has an asterisk next to it.

powercfg /SETDCVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 7516b95f-f776-4464-8c53-06167f40cc99 FBD9AA66-9553-4097-BA44-ED6E9D65EAB8 0
is equivalent to
powercfg /SETDCVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e SUB_VIDEO FBD9AA66-9553-4097-BA44-ED6E9D65EAB8 0
#>

function unhide_powersettings (
    [switch] $render = $false,
    [switch] $verbose = $false
) {
    # invoke with -render to write to file. otherwise, we'll unhide all elements with this script
    # invoke with -verbose to print each power option as it's unhidden (only applicable when render=false)
    write-host -f c "power unhide"
    if ($render) {
        write-host -f c "writing power unhide script to $psscriptroot\unhide.ps1"
    } else {
        write-host -f c "unhiding power options now"
    }

    $uidreg = '\w{8}-\w{4}-\w{4}-\w{4}-\w{12}'
    $caps = gcim -Namespace root\cimv2\power -Class Win32_PowerSettingCapabilities
    $settings = gcim -Namespace root\cimv2\power -Class Win32_PowerSetting
    $settings_insubgrp = gcim -Namespace root\cimv2\power -Class Win32_PowerSettingInSubgroup

    foreach ($cap in $caps) {
        if (! ($cap.managedelement.instanceid -match $uidreg)) {
            continue
        }
        $guid = $matches[0]

        if (! ($grp = $settings_insubgrp | where-object {$_.partcomponent.instanceid -match $guid})) {
            continue
        }
        if (! ($elem = $settings | where-object {$_.instanceid -match $guid})) {
            continue
        }
        if (! ($grp.GroupComponent.instanceid -match $uidreg)) {
            continue
        }
        $guid_grp = $matches[0]

        $descr = [string]::Format("# {0}", $elem.ElementName)
        $runcfg = [string]::Format("powercfg -attributes {0} {1} -ATTRIB_HIDE", $guid_grp, $guid)
        if ($render) {
            out-file -Encoding ASCII -FilePath ./unhide.ps1 -append -InputObject $descr
            out-file -Encoding ASCII -FilePath ./unhide.ps1 -append -InputObject $runcfg
            out-file -Encoding ASCII -FilePath ./unhide.ps1 -append -InputObject ""
            continue
        }
        if ($verbose) {
            write-host -f c "unhiding: $($elem.ElementName)"
        }
        iex "${runcfg}"
    }
}
