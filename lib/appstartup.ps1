enum Sources {
    registry
    folder
}

class app {
    [ValidateNotNullOrEmpty()][string]$name
    [ValidateNotNullOrEmpty()][string]$path
    [ValidateNotNullOrEmpty()][string]$command
    [ValidateNotNullOrEmpty()][Sources]$source
}

function startups_reg {
    $StartupPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    )
    foreach ($Path in $StartupPaths) {
        if (Test-Path $Path) {
            $pnames = get-item $Path | select-object -expandproperty Property
            if (-not $pnames) {
                continue
            }

            $pnames | ForEach-Object {
                [app]@{
                    name = $_
                    path = $Path
                    command = "none"
                    source = [Sources]::registry
                }
            }
        }
    }
}

function startups_folder {
    $StartupFolders = @(
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
        "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\Startup"
    )
    foreach ($Folder in $StartupFolders) {
        if (Test-Path $Folder) {
            Get-ChildItem -Path $Folder -File | ForEach-Object {
                [app]@{
                    name = $_.Name
                    path = $Folder
                    command = $_.FullName
                    source = [Sources]::folder
                }
            }
        }
    }
}

function startup_rm (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $name,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $source,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $path
) {
    try {
        switch ($source) {
            ([Sources]::registry) {
                Remove-ItemProperty $path -Name $name -ErrorAction Stop
                Write-Host -f green "Removed $name from registry startup path: $path"
            }
            ([Sources]::folder) {
                Remove-Item (Join-Path -Path $path -ChildPath $name) -ErrorAction Stop
                Write-Host -f green "Removed $name from startup folder: $path"
            }
        }
    } catch {
        Write-host "Failed to remove Name: $_.name" -f y
    }
}

function startups_rm (
    [string[]] $names,
    [switch] $print = $true,
    [switch] $verbose = $false
) {
    Write-Host "Retrieving startup applications" -f c
    $StartupApps = startups_reg + startups_folder
    if (-not $StartupApps) {
        Write-Host "No startup applications found." -f y
        return
    }
    if ($print) {
        if ($verbose) {$StartupApps | Format-list} else {$StartupApps.name}
    }
    if (-not $names) {
        return
    }

    $SelectedApps = @()
    foreach ($name in $names) {
        $SelectedApps += $StartupApps | where-object {$_.name -match "$name"}
    }
    if (-not $SelectedApps) {
        write-host "no startup apps found to remove" -f c
        return
    }
    foreach ($App in $SelectedApps) {
        startup_rm -Name $App.Name -Source $App.Source -Path $App.Path
    }
}
