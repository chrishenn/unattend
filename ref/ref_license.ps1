# status = 1 indicates permanent activation

Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" |
where { $_.PartialProductKey } | select Description, LicenseStatus
