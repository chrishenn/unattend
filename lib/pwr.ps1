function modern_standby_disable {
    $key = 'HKLM:\System\CurrentControlSet\Control\Power'
    SetProp $key 'PlatformAoAcOverride' 'DWORD' 0
}

function connected_standby_disable {
    $key = 'HKLM:\System\CurrentControlSet\Control\Power'
    SetProp $key 'CSEnabled' 'DWORD' 0
}

function pwr_unhide {
    # https://gist.github.com/Velocet/7ded4cd2f7e8c5fa475b8043b76561b5
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings'
    $cfg = (Get-ChildItem $key -Recurse).Name -notmatch '\bDefaultPowerSchemeValues|(\\[0-9]|\b255)$'
    foreach ($item in $cfg) {
        setprop $item.Replace('HKEY_LOCAL_MACHINE', 'HKLM:') 'Attributes' 'DWORD' 2
    }
}
