function nvdriver_insver {
    try {
        return ($(nvidia_gpu).DriverVersion.Replace('.', '')[-5..-1] -join '').insert(3, '.')
    } catch {
        return $null
    }
}

function nvdriver_install_full (
    [switch] $clean = $true,
    [switch] $force = $false,
    [switch] $gpu_ignore = $false,
    [switch] $task = $false,
    [switch] $physx = $false,
    [switch] $hdaudio = $false,
    [string] $taskday = "Sunday",
    [string] $tasktime = "12pm"
) {
    # note: depends on scoop
    # set force to install even when installed version matches latest from web
    # set clean to run nvidia installer with clean flag
    # gpu_ignore: proceed even if no nvidia gpu is found

    $pfx = "NVIDIA DRIVER:"
    write-host "$pfx {clean: $clean, force: $force, task: $task, taskday: $taskday, tasktime: $tasktime}"

    if ($gpu = (nv_wait)) {
        write-host "$pfx Found gpu: $($gpu.name)"
    } elseif ($gpu_ignore) {
        write-host "$pfx No NVIDIA GPU found but force is true; proceeding to install nvidia app"
    } else {
        throw "$pfx No NVIDIA GPU found. Exiting"
    }

    if ($ins_ver = nvdriver_insver) {
        Write-Host "$pfx Found installed driver version: $ins_ver"
    } else {
        $ins_ver = "unknown"
        write-host "$pfx Failed to find installed nvidia driver"
    }

    # latest driver version from web
    $search = 'https://gfwsl.geforce.com/services_toolkit/services/com/nvidia/services/AjaxDriverService.php' +
        '?func=DriverManualLookup' +
        '&psid=120' + # Geforce RTX 30 Series
        '&pfid=929' + # RTX 3080
        '&osID=57' + # Windows 10 64bit
        '&languageCode=1033' + # en-US; seems to be "Windows Locale ID"[1] in decimal
        '&isWHQL=1' + # WHQL certified
        '&dch=1' + # DCH drivers (the new standard)
        '&sort1=0' + # sort: most recent first(?)
        '&numberOfResults=1'

    $rsp = iwr $search -useb
    $web_ver = ($rsp.Content | ConvertFrom-Json).IDS[0].downloadInfo.Version
    if ($web_ver) {
        Write-host "$pfx Latest version from web: $web_ver"
    } else {
        throw "$pfx ERROR: No driver version found from web search"
    }

    # bug: this should be web <= installed
    if ($ins_ver -eq $web_ver -and -not $force) {
        Write-Host "The installed version $ins_ver matches latest version from web and force not set. Exiting"
        return
    }

    write-host "$pfx scoop install 7zip"
    scoop install 7zip
    $zip = $(scoop which 7z)

    Write-Host "$pfx Downloading driver"
    $tmpdir = "$HOME\nvidia_driver"
    [void](ni $tmpdir -ItemType Directory -ea 0)

    $winver = if ([Environment]::OSVersion.Version -ge (new-object 'Version' 9, 1)) {
        "win10-win11"
    } else {
        "win8-win7"
    }
    $arch = if ([Environment]::Is64BitOperatingSystem) {
        "64bit"
    } else {
        "32bit"
    }

    $url = "https://international.download.nvidia.com/Windows/$web_ver/$web_ver-desktop-$winver-$arch-international-dch-whql.exe"
    $drexe = "$tmpdir\nvidia_driver.exe"
    dl_retry $url $drexe

    Write-Host "$pfx Extracting files"
    $extdir = "$tmpdir\nvdriver_extracted"
    $extfiles = "Display.Driver NVI2 EULA.txt ListDevices.txt setup.cfg setup.exe"
    $extfiles = if ($physx) {$extfiles + ' PhysX'} else {$extfiles}
    $extfiles = if ($hdaudio) {$extfiles + ' HDAudio'} else {$extfiles}
    Start-Process $zip -NoNewWindow -a "x -bso0 -bsp1 -bse1 -aoa $drexe $extfiles -o$extdir" -wait

    $cfg = Get-Content "$extdir\setup.cfg" | Where-Object {$_ -notmatch 'name="\${{(EulaHtmlFile|FunctionalConsentFile|PrivacyPolicyFile)}}'}
    Set-Content "$extdir\setup.cfg" "$cfg" -Encoding UTF8 -Force

    Write-Host "$pfx Installing nvidia driver"
    $arg = '-passive -noreboot -noeula -nofinish -s'
    $arg = if ($clean) {$arg + " -clean"} else {$arg}
    Start-Process "$extdir\setup.exe" -a "$arg" -wait
    rm_force $tmpdir

    if ($task) {
        Write-Host "$pfx Creating A Scheduled Task..."
        [void](New-Item C:\Task -type directory -ea 0)
        [void](cp $PSCommandPath C:\Task)
        $taskname = "Nvidia-Updater"
        $description = "update nvidia driver"
        $action = New-ScheduledTaskAction -Execute "C:\Task\$($MyInvocation.ScriptName)"
        $trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval $task -DaysOfWeek $taskday -At $tasktime
        [void](Register-ScheduledTask -TaskName $taskname -Action $action -Trigger $trigger -Description $description)
    }

    if ($ins_ver = nvdriver_insver) {
        Write-Host "$pfx SUCCESS: found installed driver version: $ins_ver"
    } else {
        throw "$pfx FAILURE: failed to find installed nvidia driver"
    }
}

function nvdriver_install {
    # instead of copying out the eula files, we can patch out the refs to them in the setup.cfg manifest

    $url = 'https://us.download.nvidia.com/Windows/581.80/581.80-desktop-win10-win11-64bit-international-dch-whql.exe'
    irm -useb $url -outfile driver.exe

    $dir = ".\nvdriver"
    $files = "Display.Driver NVI2 EULA.txt ListDevices.txt setup.cfg setup.exe"
    Start-Process 7z -wait -NoNewWindow -a "x -bso0 -bsp1 -bse1 -aoa driver.exe $files -o$dir"

    $cfg = Get-Content "$dir\setup.cfg" | Where-Object {$_ -notmatch 'name=(.*)(EulaHtmlFile|FunctionalConsentFile|PrivacyPolicyFile)'}
    Set-Content "$dir\setup.cfg" "$cfg" -Encoding UTF8 -Force

    Start-Process -wait "$dir\setup.exe" -a '-s -n -noeula -nofinish -clean'
}

function nvdriver_install_ref {
    # copy all the eula files from the nvapp package that's included in the driver installer package
    $dir = ".\nvdriver"
    $files = 'Display.Driver NVI2 setup.exe setup.cfg EULA.txt ListDevices.txt nvapp\FunctionalConsent* nvapp\PrivacyPolicy nvapp\Unified_EULA\*'
    Start-Process -wait 7z -a "x -bso0 -bsp1 -bse1 -aoa driver.exe $files -o$dir"
    Start-Process -wait "$dir\setup.exe" -a '-passive -noreboot -noeula -nofinish -s -clean'
}

function nvdriver_uninstall {
    $pkg = 'Display.Driver'
    $dll = 'C:\Program Files\NVIDIA Corporation\Installer2\InstallerCore\NVI2.DLL'
    $argsl = """$dll"",UninstallPackage $pkg -silent -deviceinitiated"
    Start-Process RunDll32 -wait -a $argsl
}
