enum Env {
    machine
    user
    local
}

function path_reload {
    $mach = [Environment]::GetEnvironmentVariable('path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('path', 'User')
    $env:path = $mach + ";" + $user
}

function path_ls (
    [Parameter(Mandatory = $false)][Env] $cnt = [Env]::machine
) {
    switch ($cnt) {
        ([Env]::local) {
            $env:path.split(";")
        }
        default {
            [Environment]::GetEnvironmentVariable('path', $cnt).split(";")
        }
    }
}

function path_in (
    [Parameter(Mandatory = $true)][string] $val,
    [Parameter(Mandatory = $false)][Env] $cnt = [Env]::machine
) {
    switch ($cnt) {
        ([Env]::local) {
            $env:path.split(";").contains("$val")
        }
        default {
            [Environment]::GetEnvironmentVariable('path', $cnt).split(";").contains("$val")
        }
    }
}

function path_add (
    [Parameter(Mandatory = $true)][string] $val,
    [ValidateSet('Machine', 'User')][Env] $cnt = [Env]::machine
) {
    # add entry to path if not present

    if (path_in $val $cnt) {
        return
    }
    switch ($cnt) {
        ([Env]::local) {
            $vals = $env:path.split(";")
            $vals = $vals + $val
            $env:path = $vals -join ';'
        }
        default {
            $vals = [Environment]::GetEnvironmentVariable('path', $cnt).split(";")
            $vals = $vals + $val
            [Environment]::SetEnvironmentVariable('path', $vals -join ';', $cnt)
        }
    }
}

function path_rm (
    [Parameter(Mandatory = $true)][string] $val,
    [Parameter(Mandatory = $false)][Env] $cnt = [Env]::machine
) {
    # remove an entry from path if present
    # does a strict (case-insensitive) -ne check against $val

    switch ($cnt) {
        ([Env]::local) {
            $vals = $env:path.split(";")
            $vals = $vals | Where-Object {$_ -ne $val}
            $env:path = $vals -join ';'
        }
        default {
            $vals = [Environment]::GetEnvironmentVariable('path', $cnt).split(";")
            $vals = $vals | Where-Object {$_ -ne $val}
            [Environment]::SetEnvironmentVariable('path', $vals -join ';', $cnt)
        }
    }
}




