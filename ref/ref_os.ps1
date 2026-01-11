function osver {
    $osversion = (gcim Win32_OperatingSystem).Version
    $version = $osversion.split(".")[0]

    write-host "found os version: $osversion"
    write-host "found os major version: $version"
}
