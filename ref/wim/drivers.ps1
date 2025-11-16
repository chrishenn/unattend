$infs = Get-ChildItem -r 'C:\drivers' -Filter "*.inf"

$infs = Get-ChildItem -r . -Filter "*.inf"
foreach ($inf in $infs) {
    pnputil /add-driver $inf.FullName /install
}

Get-ChildItem . -r -filter "*.inf"

foreach ($dir in (get-childitem -r -directory .)) {
    pnputil /add-driver $dir offline /subdirs /install
}


foreach ($dir in (Get-ChildItem . -r -filter "*.inf") | split-path -parent) {
#    pnputil /add-driver /subdirs /install .
    $dir
}

Get-ChildItem . -r -filter "*.inf"
Get-ChildItem .\* -r -include @("*.inf", "*.cat", "*.sys")
