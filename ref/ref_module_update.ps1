function rm_mod (
    [Parameter(Mandatory=$true)][string] $name,
    [Parameter(Mandatory=$true)][string] $ver
) {
    Get-Module $name | where {([string]($_.Version)).StartsWith($ver)} | Remove-Module -Verbose
}
