function cfg_yml (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $file
) {
    # read a scoop packages manifest from yaml and return the relevant section for our platform
    if (-not (get-module -listavailable powershell-yaml)) {
        install-module powershell-yaml -force -SkipPublisherCheck
    }
    import-module powershell-yaml
    return (get-content $file | convertfrom-yaml).windows.client
}

function cfg_mntshare {
    if ($cfg.containskey('shares')) {
        net_mntshare $cfg.shares
    }
}

function cfg_scoop (
    [Hashtable] $cfg
) {
    if ($cfg.containskey("scoop_base")) {
        scoop_base $cfg.scoop_base
    } else {
        scoop_base
    }
    if ($cfg.containskey("scoop_bucket")) {
        scoop_bucket $cfg.scoop_bucket
    } else {
        scoop_bucket
    }
    if ($cfg.containskey("scoop_app")) {
        scoop_app $cfg.scoop_app
    }
    if ($cfg.containskey("scoop_shim")) {
        scoop_shim $cfg.scoop_shim
    }
}

function cfg_scoop_prv (
    [Hashtable] $cfg
) {
    if (-not $cfg.containskey("scoop_private")) {
        write-host -f y "WARN (scoop_private): no key scoop_private in hashtable param 'cfg'"
        return
    }
    if (-not (scoop config gh_token)) {
        if (-not (inst_app op)) {
            write-host -f r "ERROR (scoop_private): scoop gh_token not set and op is not installed"
            return
        }
        if (-not $env:OP_SERVICE_ACCOUNT_TOKEN) {
            write-host -f r "ERROR (scoop_private): scoop gh_token not set and OP_SERVICE_ACCOUNT_TOKEN not set"
            return
        }
        scoop config gh_token (op read "op://homelab/github/credential")
        if (-not (scoop config gh_token)) {
            write-host -f r "ERROR (scoop_private): tried to set scoop gh_token but it's still empty"
            return
        }
    }
    scoop_app $cfg.scoop_private
}
