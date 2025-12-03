function scoop_base (
    [string[]] $basepkgs = @()
) {
    $minpkgs = @('7zip', 'git', 'aria2', 'dark', 'innounp', 'lessmsi', 'sudo', 'pwsh')
    foreach ($pkg in $minpkgs) {
        if (-not $basepkgs.contains($pkg)) {
            $basepkgs += $pkg
        }
    }
    if (-not (gcm_app scoop)) {
        iex "& {$(irm get.scoop.sh -useb)} -RunAsAdmin"
        scoop install @basepkgs
        scoop config aria2-warning-enabled false
        scoop update
        pwsh -c '& {Set-ExecutionPolicy -force -scope localmachine -ExecutionPolicy bypass}'
        pwsh -c '& {Set-ExecutionPolicy -force -scope currentuser -ExecutionPolicy bypass}'
    }
}

function scoop_bucket (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $pair
) {
    # pair may be just a bucket name ('known buckets') or a pair ('name url')
    $split = $pair.split(' ')
    $bs = (scoop export | ConvertFrom-Json).buckets
    $inst = ($bs | where-object {$_.name -eq $split[0]} | measure).count -gt 0
    if (-not $inst) {
        try {
            scoop bucket add @split
        } catch {
            write-host "error while adding bucket $pair"
        }
    }
}

function scoop_buckets (
    [string[]] $buckets = @()
) {
    # bucket add is idempotent; no need for manual check
    foreach ($name in $buckets) {
        if (-not $name) {
            continue
        }
        try {
            $tmp = $name.split(' ')
            scoop bucket add @tmp
        } catch {
            echo "error while adding bucket: $name"
        }
    }
    scoop update
}

function scoop_apps (
    [string[]] $apps
) {
    # you can loop over these, try/catching each one; it may be much slower, though
    # the tradeoff is that one install failure will cascade into (unpredictable?) other install failures
    try {
        scoop install @apps
    } catch {
        echo "error while installing packages: $apps"
    }
}

function scoop_shim (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $pair
) {
    # adding shims using `scoop add` is NOT idempotent, so this check is necessary
    $split = $pair.split(' ')
    if (-not ($split[0] -and $split[1])) {
        write-host -f y "scoop shim: malformed shim: $pair"
        return
    }
    if (scoop shim info $split[0]) {
        write-host -f green "scoop shim: already exists for: $pair"
    } else {
        scoop shim add $split[0] $(scoop which $split[1])
    }
}

function scoop_shims (
    [string[]] $shims = @()
) {
    # adding a shim is NOT idempotent; manual check is needed
    foreach ($pair in $shims) {
        if (-not $pair) {
            continue
        }
        try {
            scoop_shim $pair
        } catch {
            echo "error while adding shim: $pair"
        }
    }
}

function scoop_boot (
    [Hashtable] $cfg
) {
    if ($cfg.containskey("scoop_base")) {
        scoop_base $cfg.scoop_base
    } else {
        scoop_base
    }
    if ($cfg.containskey("scoop_bucket")) {
        scoop_buckets $cfg.scoop_bucket
    } else {
        scoop_buckets
    }
    if ($cfg.containskey("scoop_app")) {
        scoop_apps $cfg.scoop_app
    }
    if ($cfg.containskey("scoop_shim")) {
        scoop_shims $cfg.scoop_shim
    }
}
