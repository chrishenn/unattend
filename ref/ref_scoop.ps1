function scoop_bucket (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $pair
) {
    # note: checking for existing bucket is not necessary, since 'bucket add' is idempotent
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
