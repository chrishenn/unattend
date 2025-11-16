function autologin (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $user,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $pass
) {
    $key = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
    SetProp $key 'DefaultUserName' 'String' "$user"
    SetProp $key 'DefaultPassword' 'String' "$pass"
    SetProp $key 'AutoAdminLogon' 'String' '1'
}

function autologin_it {
    if (!($user = Read-Host "enter username for autologin user. Default = 'chris'")) {$user = "chris"}
    if (!($pass = Read-Host "enter password for autologin user. Default = 'password'")) {$pass = "password"}
    autologin "$user" "$pass"
}
