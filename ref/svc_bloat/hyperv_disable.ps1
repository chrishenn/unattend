$hyperv_svc_names = @(
  "AppVClient",
  "HvHost",
  "vmickvpexchange",
  "vmicguestinterface",
  "vmicshutdown",
  "vmicheartbeat",
  "vmcompute",
  "vmicvmsession",
  "vmicrdv",
  "vmictimesync",
  "vmms",
  "vmicvss"
)

write-host "Stopping Hyper-V Services"
svc_stop $hyperv_svc_names

write-host "Disabling Hyper-V Services"
svc_disable $hyperv_svc_names
