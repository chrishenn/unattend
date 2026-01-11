function ah_deps {
    write-host "Installing autohotkey and compilation dependencies"
    if ($PSVersionTable.psversion.major -lt 7) {
        write-host -f r"ERROR: pwsh version too low: use pwsh >= 7"
        exit 1
    }
    if (! (inst_gcm scoop)){
        scoop_base
    }
    if (! (inst_scoop "autohotkey")) {
        scoop install autohotkey
    }

    $ahdir = "$(scoop prefix autohotkey)"
    $ahk = "$ahdir\Compiler\Ahk2Exe.exe"
    $base = "$ahdir\v2\autohotkey64.exe"
    $installer = "$ahdir\UX\install-ahk2exe.ahk"

    if (! (test-path $base)) {
        write-host -f r "ERROR: autohotkey64.exe was not found at: $base"
        exit 1
    }
    if (! (test-path $ahk)) {
        start-process $base -a "/script $installer /silent /base $base" -Wait
    }
    if (! (test-path $ahk)) {
        write-host -f r "ERROR: ahk2exe.exe compiler was not found at: $ahk"
        exit 1
    }
}

function ah_compile (
    [Parameter(Mandatory = $false)][string] $scripts,
    [Parameter(Mandatory = $false)][string] $compiled
) {
    # compile scripts from the scripts folder
    [void](mkdir -force -ea 0 $compiled)
    foreach ($path in $(gci -Path $scripts -Filter *.ahk -Name)) {
        write-host -f c "Compiling $path"
        $name = split-path $path -LeafBase
        start-process $ahk -a "/silent verbose /in $path /out $compiled\AH$name /base $base" -Wait
    }
}

function ah_clean (
    [string][ValidateNotNullOrEmpty()] $compiled
) {
    # clean compiled binaries out of the compiled folder
    rm -r -force -ea 0 $compiled
}

function ah_kill {
    # kill autohotkey binaries in startup folder. Match using name like 'AH*.exe'
    $startup = [System.Environment]::GetFolderPath("CommonStartUp")
    foreach ($exe in (gci $startup -Filter AH*.exe)) {
        $name = split-path $exe -Leafbase
        if (get-process -name $name -ea 0) {
            write-host -f c "killing: $name"
            stop-process -name $name -force -ea 0
        }
        wait-process -name $name -ea 0
    }
}

function ah_start {
    # start autohotkey binaries in startup folder. Match using name like 'AH*.exe'
    $startup = [System.Environment]::GetFolderPath("CommonStartUp")
    foreach ($path in (gci $startup -Filter AH*.exe).resolvedtarget) {
        write-host -f c "starting: $path"
        start-process "$path"
    }
}

function ah_copy (
    [string][ValidateNotNullOrEmpty()] $compiled
) {
    # copy binaries from the compiled folder to the auto startup folder
    $startup = [System.Environment]::GetFolderPath("CommonStartUp")
    cp -r -force $compiled\*.exe $startup
}

