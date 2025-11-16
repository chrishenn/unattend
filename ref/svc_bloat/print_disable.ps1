#### disable print services

(get-childitem "$PSScriptRoot/../lib/*.ps1").foreach({. $_.FullName})

$print_svc_names = @(
    "Spooler",
    "PrintNotify"
)

$print_svc_stems = @(
    "PrintWorkflowUserSvc_"
)

svcs_stems $print_svc_stems
$print_svc_names += $print_svc_stems
write-host "found services: $print_svc_names"

write-host "Stopping Print Services"
svcs_stop $print_svc_names

write-host "Disabling Print Services"
svcs_disable $print_svc_names
