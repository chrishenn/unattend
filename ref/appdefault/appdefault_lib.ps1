function zen_default {
    # note: nonworking

    # probably best to use this
    # ref\appdefault.ps1 -ProgId $progid

    # key name not found. probably different in each install
    # this requires that UCPD has been disabled, with a reboot after

    # set zen as default browser
    $cls = gci "REGISTRY::HKEY_USERS\S-1-5-21-574101447-4167929876-2884353096-1000_Classes" -recurse |
        where-object {$_.name -like "*FirefoxURL*"} |
        select-object -first 1
    $progid = $cls.name | split-path -leaf

    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice'
    setprop $key ProgID 'String' $progid
    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice'
    setprop $key ProgID 'String' $progid
    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\.avif\UserChoice'
    setprop $key ProgID 'String' $progid
    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\.webp\UserChoice'
    setprop $key ProgID 'String' $progid
    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\.htm\UserChoice'
    setprop $key ProgID 'String' $progid
    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\.html\UserChoice'
    setprop $key ProgID 'String' $progid
    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\.shtml\UserChoice'
    setprop $key ProgID 'String' $progid
    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\.xhtml\UserChoice'
    setprop $key ProgID 'String' $progid
    $key = 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\.pdf\UserChoice'
    setprop $key ProgID 'String' $progid
}
