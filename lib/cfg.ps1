function cfg_yml_req {
    if (-not (get-module -listavailable powershell-yaml)) {
        install-module powershell-yaml -force -SkipPublisherCheck
    }
    import-module powershell-yaml
}

function cfg_op_req {
    if (-not (inst_gcm op)) {
        write-host -f y "WARN cfg_op_req: op cli not found. Attempting scoop install"
        scoop_base 1password-cli
    }
    if (-not $env:OP_SERVICE_ACCOUNT_TOKEN) {
        write-host -f r "ERROR cfg_op_req: env:OP_SERVICE_ACCOUNT_TOKEN not set"
    }
    return ($env:OP_SERVICE_ACCOUNT_TOKEN -and (inst_gcm op))
}

function cfg_yml (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $file
) {
    write-host -f c 'cfg yml'
    cfg_yml_req
    return (get-content $file | convertfrom-yaml).windows.client
}

function cfg_yml_sec (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $file
) {
    write-host -f c 'cfg yml sec'
    cfg_yml_req
    if (-not (cfg_op_req)) {
        write-host -f r "ERROR cfg_yml_sec: cfg_op_req failed"
        return $null
    }
    return (op inject -i $file | convertfrom-yaml).windows.client
}

function cfg_gh_req (
    [Hashtable] $cfg,
    [string] $cfgfile
) {
    if (scoop config gh_token) {
        return $true
    }
    if (-not $cfg.containskey('gh_token')) {
        write-host -f r 'ERROR cfg_gh_req: no key gh_token found in [hashtable]cfg'
        return $false
    }
    if (-not ($cfg_sec = cfg_yml_sec $cfgfile)) {
        write-host -f r 'ERROR cfg_gh_req: cfg_yml_sec failed'
        return $false
    }
    scoop config gh_token $cfg_sec.gh_token
    if (-not (scoop config gh_token)) {
        write-host -f r 'ERROR cfg_gh_req: tried to set scoop gh_token but its still empty'
        return $false
    }
    return $true
}

function cfg_mntshare ([hashtable] $cfg) {
    write-host -f c 'cfg mntshare'
    if ($cfg.containskey('shares')) {
        net_mntshare $cfg.shares
    }
}

function cfg_scoop (
    [Hashtable] $cfg
) {
    write-host -f c 'cfg scoop'
    if ($cfg.containskey('scoop_base')) {
        scoop_base $cfg.scoop_base
    } else {
        scoop_base
    }
    if ($cfg.containskey('scoop_bucket')) {
        scoop_bucket $cfg.scoop_bucket
    }
    if ($cfg.containskey('scoop_app')) {
        scoop_app $cfg.scoop_app
    }
    if ($cfg.containskey('scoop_shim')) {
        scoop_shim $cfg.scoop_shim
    }
}

function cfg_scoop_prv (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][Hashtable] $cfg,
    [string] $cfgfile = ''
) {
    write-host -f c 'cfg scoop private'
    if (-not $cfg.containskey('scoop_private')) {
        return
    }
    if (-not (cfg_gh_req $cfg $cfgfile)) {
        return
    }
    scoop_app $cfg.scoop_private
}

function cfg_autologin ([string] $cfgfile) {
    if (-not ($cfg_sec = cfg_yml_sec $cfgfile)) {
        write-host -f r 'ERROR cfg_autologin: cfg_yml_sec failed'
        return
    }
    autologin $cfg_sec.autologin.user $cfg_sec.autologin.pass
}
