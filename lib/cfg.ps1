function cfg_yml (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $file
) {
    # read a scoop packages manifest from yaml and return the relevant section for our platform
    if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
        Install-Module powershell-yaml -force -SkipPublisherCheck
    }
    Import-Module powershell-yaml
    return (get-content $file | convertfrom-yaml).windows.client
}
