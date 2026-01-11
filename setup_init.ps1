param(
    [string] $log = ''
)

if ($log) {
    Start-Transcript -Append $log
}
$erroractionpreference = 'Continue'
$ConfirmPreference = 'None'

$ppnames = (get-packageprovider).name
if (-not ($ppnames -contains 'nuget')) {
    install-packageprovider nuget -force -ea 0
}
if (-not ($ppnames -contains 'powershellget')) {
    install-packageprovider powershellget -force -ea 0
}
if ($PSVersionTable.PSVersion.Major -le 5) {
    import-module Appx
} else {
    import-module Appx -SkipEditionCheck
}
if (-not (get-module -ListAvailable chplib)) {
    install-module chplib -force -skippublishercheck
}
import-module chplib -force

# local libs take precedence by sourcing last
(gci "$psscriptroot\lib" -filter *.ps1).foreach({. $_.fullname})

# cfg file variable pushed into global context puddle :/
$cfg = cfg_yml "$psscriptroot\cfg.yml"
