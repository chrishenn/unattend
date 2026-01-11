function nvapp_url (
    [string] $search
) {
    $url = $null
    $rsp = (iwr $search -usebasicparsing).Content
    if ($rsp -match 'https:\/\/us\.download\.nvidia\.com\/nvapp\/client\/[\d\.]+\/NVIDIA_app_v[\d\.]+\.exe') {
        $url = $matches[0]
    } elseif ($rsp -match '<a[^>]*href="([^"]*nv[^"]*app[^"]*\.exe)"[^>]*>\s*<span[^>]*>DownloadNow<\/span>') {
        $url = $matches[1]
    } elseif ($rsp -match 'href="([^"]*nv[^"]*app[^"]*\.exe)"') {
        $url = $matches[1]
    }
    return $url
}

function nvapp_insver {
    $appPath = Join-Path -Path $env:ProgramFiles -ChildPath "NVIDIA Corporation\NVIDIA app\CEF\NVIDIA app.exe"
    if (Test-Path $appPath) {
        return (Get-Item $appPath | Select-Object -ExpandProperty VersionInfo).ProductVersion
    }
    return $null
}

function nvapp_install (
    [switch] $force = $false,
    [switch] $gpu_ignore = $false,
    [string] $edition = "public"
) {
    # download and install the latest NVIDIA App
    # edition: {"Enterprise", "Public"}
    # force: proceed even if installed app ver matches latest ver
    # gpu_ignore: proceed even if no nvidia gpu found

    $pfx = "NVIDIA APP:"
    Write-host "$pfx {Force: $force, Edition: $edition}"

    if ($gpu = (hw_nvwait)) {
        write-host "$pfx Found gpu: $($gpu.name)"
    } elseif ($gpu_ignore) {
        write-host "$pfx No NVIDIA GPU found but force is true; proceeding to install nvidia app"
    } else {
        throw "$pfx No NVIDIA GPU found. Exiting"
    }

    $search = if ($edition -eq "Enterprise") {
        "https://www.nvidia.com/en-us/software/nvidia-app-enterprise/"
    } else {
        "https://www.nvidia.com/en-us/software/nvidia-app/"
    }
    Write-host "$pfx Scraping URL: $search"
    if ($dl_url = nvapp_url $search) {
        Write-host "$pfx Found download url: $dl_url"
    } else {
        throw "$pfx ERROR: No download url found"
    }

    $web_ver = if ($dl_url -match '_v(\d+\.\d+\.\d+\.\d+)\.exe') {
        $matches[1]
    } else {
        "Unknown"
    }
    Write-host "$pfx Found download version: $web_ver"

    # bug: this should check for installed <= latest
    $inst_ver = nvapp_insver
    if ($inst_ver -and $inst_ver -eq $web_ver -and -not $force) {
        Write-host "$pfx Installed version $inst_ver matches latest from web, and force not set. Exiting"
        return
    }

    Write-host "$pfx Downloading nvidia app installer"
    $installer = "$HOME\nvidia_app.exe"
    net_dlretry $dl_url $installer

    Write-host "$pfx Installing nvidia app"
    Start-Process $installer -a "-s -noreboot -noeula -nofinish -nosplash" -Wait
    rm $installer

    if ($inst_ver = nvapp_insver) {
        Write-host "$pfx SUCCESS: found installed version: $inst_ver"
    } else {
        throw "$pfx ERROR: Could not find installed app after running installer"
    }
}

function nvapp_uninstall {
    $pkg = 'Display.NvApp'
    $dll = 'C:\Program Files\NVIDIA Corporation\Installer2\InstallerCore\NVI2.DLL'
    $argsl = """$dll"",UninstallPackage $pkg -silent -deviceinitiated"
    Start-Process RunDll32 -a $argsl -Wait
    rm -r -force 'C:\\program files\\NVIDIA Corporation\\NVIDIA App'
}
