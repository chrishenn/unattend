function appx_find (
    [string] $pattern
) {
    return (Get-AppxPackage -allusers | Where-Object {$_.packagefullname -like $pattern})
}

function appx_rm (
    [string] $pattern
) {
    appx_find "$pattern" | Remove-AppxPackage -allusers
}

function appxsys_find (
    [string] $pattern
) {
    Get-AppxProvisionedPackage -allusers -online | Where-Object {$_.packagename -like $pattern}
}

function appxsys_rm (
    [string] $pattern
) {
    appxsys_find "$pattern" | Remove-AppxProvisionedPackage -allusers -online $pkg
}
