function scoop_base (
    [string[]] $basepkgs = @('7zip', 'git', 'aria2', 'dark', 'innounp', 'lessmsi', 'sudo', 'pwsh')
) {
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
    [string[]] $buckets = @('extras', 'versions', 'nerd-fonts', 'chris https://github.com/chrishenn/scoops')
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
        write-host -f yellow "scoop shim: malformed shim: $pair"
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

function scoop_boot_private (
    [Hashtable] $cfg
) {
    if (-not $cfg.containskey("scoop_private")) {
        write-host -f yellow "WARN (scoop_private): not key scoop_private in hashtable param 'cfg'"
        return
    }
    if (-not (scoop config gh_token)) {
        if (-not (installed op)) {
            write-host -f red "ERROR (scoop_private): scoop gh_token not set and op is not installed"
            return
        }
        if (-not $env:OP_SERVICE_ACCOUNT_TOKEN) {
            write-host -f red "ERROR (scoop_private): scoop gh_token not set and OP_SERVICE_ACCOUNT_TOKEN not set"
            return
        }
        scoop config gh_token (op read "op://homelab/github/credential")
        if (-not (scoop config gh_token)) {
            write-host -f red "ERROR (scoop_private): tried to set scoop gh_token but it's still empty"
            return
        }
    }
    scoop_apps $cfg.scoop_private
}
