function bounce_shell {
    stop-process -name explorer -force
}

function bounce_audio {
    restart-service audiosrv
    restart-service AudioEndpointBuilder
}

function bounce_net {
    ipconfig /release
    ipconfig /flushdns
    ipconfig /registerdns
    ipconfig /renew
    stop-service -force -ea 0 "dns client"
    start-service "dns client"
    netsh winsock reset all
    netsh int ip reset all
}
