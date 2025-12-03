function intel_checkver (
    [string] $src
) {
    $html = curl -s $src
    $ver = [regex]::Matches($html, 'name="DownloadVersion" content="(?<version>[\d.]+)"')
    $url = [regex]::Matches($html, 'download-button(.*)"https://downloadmirror.intel.com/(?<url>.*exe)"')
    return [string]::Format('{0}|{1}', $ver[0].groups['version'].value, $url[0].groups['url'].value)
}

function checkver_bt {
    return intel_checkver 'https://www.intel.com/content/www/us/en/download/18649/intel-wireless-bluetooth-drivers-for-windows-10-and-windows-11.html'
}

function checkver_inf {
    return intel_checkver 'https://www.intel.com/content/www/us/en/download/19347/chipset-inf-utility.html'
}
