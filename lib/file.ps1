function takeowner (
    [Parameter(Mandatory = $true)][string] $path,
    [Parameter(Mandatory = $false)][string] $user = 'BUILTIN\Administrators'
) {
    # take ownership
    $acl = Get-Acl "$path"
    $acl.SetOwner([System.Security.Principal.NTAccount]$user)
    [void](Set-Acl $path $acl)

    # inheritance
    $acl = Get-Acl "$path"
    $acl.SetAccessRuleProtection($True, $False) # disable
#    $acl.SetAccessRuleProtection($false, $true) # enable
    [void](Set-Acl $path $acl)

    # add full access rules for {user, everyone}
    $acl = Get-Acl "$path"
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($user, 'FullControl', 'Allow')
    $acl.AddAccessRule($rule)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule('Everyone', 'FullControl', 'Allow')
    $acl.AddAccessRule($rule)

    # remove any deny rules
    $denies = $acl.access | where-object {$_.AccessControlType -eq "Deny"}
    foreach ($rule in $denies) {
        $acl.RemoveAccessRule($rule)
    }
    [void](Set-Acl $path $acl)

    $subp = get-childitem $path -ea 0
    if ($subp) {
        if (Get-Member -inputobject $subp -name 'SetSecurityDescriptor' -Membertype Methods) {
            [void](Set-Acl $subp $acl)
        }
    }
    if ($?) {
        write-host -f green "took ownership: $path"
    }
}

function rm_force (
    [Parameter(Mandatory = $true)][string] $path
) {
    if (-not (test-path $path)) {
        write-host -f y "not found: $path"
        return
    }
    [void](takeowner "$path")
    [void](rm -r -force -ea 0 "$path")
    if ($?) {
        write-host -f green "removed: $path"
    }
}

function file_unblock {
     # not sure what this is
     get-childitem $HOME -Recurse | unblock-file
}

function find_path (
    [string] $root,
    [string] $tgt
) {
    # recursive search from $root for file $tgt
    return (robocopy $root con $tgt /l /s /mt /njh /njs /ns /nc /ndl /np).Trim() -ne ''
}

function find_path_cs (
    [string] $root,
    [string] $tgt
) {
    # recursive search from $root for file $tgt
    return [IO.Directory]::GetFiles(
        $root,
        $tgt,
        [IO.EnumerationOptions]@{AttributesToSkip = 'ReparsePoint'; RecurseSubdirectories = $true; IgnoreInaccessible = $true}
    )
}
