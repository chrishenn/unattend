function reg_own (
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
