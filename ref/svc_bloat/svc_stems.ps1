# disable bloat services

(get-childitem "$PSScriptRoot/../lib/*.ps1").foreach({. $_.FullName})

# starts with stem plus random chars: to search for full svc name and disable
$stems = @(
    "AarSvc_", # conversational agent
    "MessagingService_", # mms messaging
    "OneSyncSvc_", # onedrive sync
    "WpnUserService_", # push notifications
    "PimIndexMaintenanceSvc_", # contact data maintenance
    "BcastDVRUserService_"      # gamedvr
)

"disabling service names from stems"
svcs_stems $stems
svcs_disable $stems
