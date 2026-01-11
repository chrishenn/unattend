#### enable print services

(gci "$PSScriptRoot/../lib/*.ps1").foreach({. $_.FullName})

$print_svc_names = @("Spooler","PrintNotify")
$print_svc_stems = @("PrintWorkflowUserSvc_")

svc_stems $print_svc_stems
$print_svc_names += $print_svc_stems
write-host "found services: $print_svc_names"

write-host "Enabling Print Services"
svc_startup $print_svc_names 3

write-host "Starting Print Services"
svc_start $print_svc_names
