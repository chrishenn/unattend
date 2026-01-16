function audio_props {
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render'
    $devs = gci $key
    foreach ($dev in $devs) {
        $devp = $dev.name.replace('HKEY_LOCAL_MACHINE', 'HKLM:')
        $devp = "$devp\properties"
        $devp
    }
}

function audio_props_2 {
#    cd ".\SetACL"
#    $key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture'
#    SetACL.exe -on $key -ot reg -actn setowner -ownr "n:NT Authority\System" -rec Yes
#    SetACL.exe -on $key -ot reg -actn ace -ace "n:NT Authority\System" -rec Yes

    $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture\*\*\"
    Get-ItemProperty $key -name "{b3f8fa53-0004-438e-9003-51a46e139bfc},3" `
        | % {Set-ItemProperty -path $_.PSPath -name "{b3f8fa53-0004-438e-9003-51a46e139bfc},3" -type Dword -value 0}

    $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture\*\*\"
    Get-ItemProperty $key -name "{b3f8fa53-0004-438e-9003-51a46e139bfc},4" `
        | % {Set-ItemProperty -path $_.PSPath -name "{b3f8fa53-0004-438e-9003-51a46e139bfc},4" -type Dword -value 0}
}

function audio_props_3 {
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render'
    $keyn = '{9e8c7d26-7e4b-4c41-a1e3-25b844d44691},3'

    $one = gci $key -Recurse
    $two = $one | Where-Object {(Get-ItemProperty $_.PSPath -name $keyn)}

    $two = $one | Where-Object {(Get-ItemProperty $_.PSPath -Name '{1da5d803-d492-4edd-8c23-e0c0ffee7f0e},5' -ea 0)}
    $thr = $two | ForEach-Object {Set-ItemProperty -Path $_.PSPath -Name '{1da5d803-d492-4edd-8c23-e0c0ffee7f0e},5' -Value '1'}
}

function audio_system_sounds {
    # copied from schneegans unattend. runs under the 'default user' pass
    $excludes = gci 'Registry::HKU\DefaultUser\AppEvents\EventLabels' |
        Where-Object {($_ | Get-ItemProperty).ExcludeFromCPL -eq 1;} |
        Select-Object -ExpandProperty 'PSChildName'

    gci -Path 'Registry::HKU\DefaultUser\AppEvents\Schemes\Apps\*\*' |
        Where-Object -Property 'PSChildName' -NotIn $excludes |
        gci -Include '.Current' | Set-ItemProperty -Name '(Default)' -Value ''
}
