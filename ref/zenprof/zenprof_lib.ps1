function zen_backup (
    [string] $src,
    [string] $dst
) {
    cp -rf $src\chrome $dst
    cp -rf $src\extensions $dst
    cp -rf $src\storage $dst
    cp -f $src\*.sqlite $dst
    cp -f $src\*.sqlite-wal $dst
    cp -f $src\*.sqlite-shm $dst
    cp -f $src\*.mozlz4 $dst
    cp -f $src\*.sqlite-journal $dst
    cp -f $src\*.lz4 $dst
    cp -f $src\*.db $dst
}

function zen_install {
    $prof_src = "$repo\zen"
    if (! (test-path $prof_src)) {
        write-host -f y "no zen profile found under playbook\resources\zen. skipping profile install"
        return
    }

    $prof_tgt = "$HOME\scoop\persist\zen-browser"
    if (-not $prof_tgt) {
        write-host -f r "error: couldn't find system default installed profile dir"
        return 1
    }
    cp -r -force -ea 0 "$prof_src" "$prof_tgt"
    rm -force -ea 0 "$env:appdata\microsoft\windows\start menu\programs\{-brand-shortcut-name} Private Browsing.lnk"
}
