function file_unblock {
     # not sure what this is
     gci $HOME -Recurse | unblock-file
}

function find_path (
    [string] $root,
    [string] $tgt
) {
    # recursive search from $root for file $tgt
    return (robocopy $root con $tgt /l /s /mt /njh /njs /ns /nc /ndl /np).Trim() -ne ''
}

function find_path_cs (
    [string] $root,
    [string] $tgt
) {
    # recursive search from $root for file $tgt
    return [IO.Directory]::GetFiles(
        $root,
        $tgt,
        [IO.EnumerationOptions]@{AttributesToSkip = 'ReparsePoint'; RecurseSubdirectories = $true; IgnoreInaccessible = $true}
    )
}
