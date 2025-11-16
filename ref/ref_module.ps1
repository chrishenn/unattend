# example module installation

Write-Host "Installing Path-Utils"
Write-Host "====================="

$pathUtilsPath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\path-utils"
New-Item $pathUtilsPath -ItemType Directory -Force

$srcPath = "./path-utils.psm1"
if (-not (Test-Path $srcPath)) {
    $srcPath = "$PSScriptRoot\path-utils.psm1"
}
Copy-Item $srcPath -Destination $pathUtilsPath

Remove-Module path-utils -ErrorAction SilentlyContinue
Import-Module path-utils

$UserModulesPath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"
$PSModulePath = [Environment]::GetEnvironmentVariable('PSModulePath', 'Machine')
if(-not $PSModulePath.contains($UserModulesPath)) {
    [Environment]::SetEnvironmentVariable('PSModulePath', "$PSModulePath;$UserModulesPath", 'Machine')
}

Write-Host "Path-Utils installed"


## then the path-utils.psm1

function Get-Path
{
    ([Environment]::GetEnvironmentVariable("path", "machine")).Split(";") | Sort-Object
}

function Get-SanitizedPath([string]$path) {
    return $path.Replace('/', '\').Trim('\')
}

function Add-SessionPath([string]$path) {

    $sanitizedPath = Get-SanitizedPath $path

    foreach($item in $env:path.Split(";")) {
        if($sanitizedPath -eq (Get-SanitizedPath $item)) {
            return # already added
        }
    }

    $env:path = "$sanitizedPath;$env:path"
}

Export-ModuleMember -Function Get-Path, Add-SessionPath
