function check_deps () {
    if (-not (Get-Command "7z" -ErrorAction SilentlyContinue)) {
        write-host "Error: this script depends on 7zip. please install it to continue"
        exit 1
    }
    $oscdimg = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
    if (-not (Get-Command "$oscdimg" -ErrorAction SilentlyContinue)) {
        write-host "Error: this script depends on oscdimg. please install it to continue"
        write-host "if you have chocolatey: choco install windows-adk-oscdimg"
        exit 1
    }
    if (-not (test-path "$tmp\drivers\*")) {
        write-host "`nError: tmp\drivers folder is empty. No drivers to install."
        exit 1
    }
}

function read_wim ($wim, [ref]$indexes) {
    if (-not (test-path $wim -PathType Leaf)) {
        write-host "Error: couldn't find file at path $wim"
        exit 1
    }

    # wiminfo is an array of strings, output of info from dism
    $wiminfo = Dism /Get-WimInfo /WimFile:"$wim"
    Write-host "$wiminfo"

    foreach ($line in $wiminfo) {
        if ($line.indexof("Index :") -ge 0) {

            $img_i = $line.split(':')[1].trim()
            write-host "`n found image index: $img_i `n"

            $indexes.value += $img_i
        }
    }
}

function dism_offline {
    check_deps
    $tmp = ".\tmp"
    New-Item -ItemType Directory -Force -Path "$tmp"
    $tmp = Resolve-Path "$tmp"

    if ($args.count -gt 0) {
        $param = $args[0]
        if ($param -ne "clean") {
            write-host "Error: The only acceptable arg is 'clean' when one is specified."
            exit 1
        }
        $clean = $true
        write-host "`n`n making clean tmp directories"
    } else {
        $clean = $false
        write-host "`n`n Not making clean tmp directories"
    }

    $src_iso = Get-ChildItem *.iso -file | select -first 1
    write-host "selected source iso $src_iso"

    if ($clean) {
        # todo make sure there's nothing mounted in the mount dir
        if (test-path $tmp) {
            remove-item -Recurse "$tmp\iso"
        }
        # if (test-path $tmp){ remove-item -Recurse $tmp\mount }
    }

    # force just turns off the error if the path exists. does not overwrite subdirs
    New-Item -ItemType Directory -Force -Path "$tmp"
    New-Item -ItemType Directory -Force -Path "$tmp\drivers"
    New-Item -ItemType Directory -Force -Path "$tmp\iso"
    New-Item -ItemType Directory -Force -Path "$tmp\mount"

    if ((test-path "$tmp\iso\*") -and -not ($clean)) {
        write-host "`nError: tmp\iso folder has files in it but clean flag is not set. Use clean arg to overwrite."
        exit 1
    }
    if ($clean) {
        Remove-Item -Recurse "$tmp\iso"
    }
    start-process 7z.exe -wait -NoNewWindow -argumentlist "x", "-y", "-o$tmp\iso", "$src_iso"

    $inst_wim = "$tmp\iso\sources\install.wim"
    $inst_indexes = $()

    $boot_wim = "$tmp\iso\sources\boot.wim"
    $boot_indexes = $()

    read_wim ($inst_wim) ([ref]$inst_indexes)
    read_wim ($boot_wim) ([ref]$boot_indexes)

    Write-Host "inst indexes: $inst_indexes"
    Write-Host "boot indexes: $boot_indexes"

    foreach ($img_i in $inst_indexes) {
        # right now I can't get the image to mount
        Dism /Mount-Image /ImageFile:"$inst_wim" /Index:"$img_i" /MountDir:"$tmp\mount"
        Dism /Image:"$tmp\mount" /Add-Driver /Driver:"$tmp\drivers" /Recurse
        Dism /Unmount-Image /MountDir:"$tmp\mount" /Commit
    }

    # untested
    oscdimg.exe -m -o -u2 -udfver102 -bootdata:2#p0,e,bc:\iso\boot\etfsboot.com#pEF,e,bc:\iso\efi\microsoft\boot\efisys.bin c:\iso c:\Win.iso

    Dism /Mount-Image /ImageFile:"$boot_wim" /Index:"$img_i" /MountDir:"$tmp\mount"
    Dism /Image:"$tmp\mount" /Add-Driver /Driver:"$tmp\drivers" /Recurse
    Dism /Unmount-Image /MountDir:"$tmp\mount" /Commit

    # check that the drivers were added before commit and unmount
    # Dism /Image:C:\test\offline /Get-Drivers

    # this mount command worked to mount boot.wim. Seems to be identical to mount-image
    dism /mount-wim /wimfile:iso\sources\boot.wim /mountdir:mount /index:1
    dism /mount-wim /wimfile:"$tmp\iso\sources\boot.wim" /mountdir:"$tmp\mount" /index:1
    # dism /unmount-wim /mountdir:mount /discard
}
