function keyadd (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $key
) {
    if (!(Test-Path "$key")) {
        [void](ni "$key" -Force)
    }
}

function propexist (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $key,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $val
) {
    # when key has no properties, this is null
    $prop = Get-ItemProperty $key -ea 0
    if ($null -eq $prop) {
        return $false
    }
    if ($null -eq ($prop | Select-Object -ExpandProperty $val -ea 0)) {
        return $false
    }
    return $true
}

function setprop (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $key,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $name,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $type,
    [parameter(Mandatory = $true)] $Value
) {
    keyadd "$key"
    if (-not (propexist "$key" "$name")) {
        [void](new-itemProperty "$key" -Name "$name" -PropertyType $type -Value $Value -Force)
    } else {
        [void](Set-ItemProperty "$key" -Name "$name" -Type $type -Value $Value -Force)
    }
}

function takeowner_reg (
    [Parameter(Mandatory = $true)][string] $path,
    [Parameter(Mandatory = $false)][string] $user = $env:USERNAME
) {
    # todo: should this be $user = 'BUILTIN\Administrators'?
    $acl = Get-Acl "$path"
    $acl.SetOwner([System.Security.Principal.NTAccount]$user)
    $acl.SetAccessRuleProtection($True, $False)
    $rule = New-Object System.Security.AccessControl.RegistryAccessRule($user, 'FullControl', 'Allow')
    $acl.SetAccessRule($rule)
    Set-Acl $path $acl
}
