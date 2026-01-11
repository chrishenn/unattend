$infs = gci "dir" -r -Filter "*inf"
foreach ($inf in $infs) {
    pnputil /add-driver $inf.fullname /install
}

# no need to search recursively
# pnputil /add-driver *.inf /install /subdirs

function pwshdev {
    Install-Module DeviceManagement -force -SkipPublisherCheck
    import-module devicemanagement
    install-devicedriver -InfFilePath "here.inf"
}
