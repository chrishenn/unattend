function shell_bounce {
    stop-process -name explorer -force
}

function audio_bounce {
    restart-service audiosrv
    restart-service AudioEndpointBuilder
}

function net_bounce {
    ipconfig /release
    ipconfig /flushdns
    ipconfig /registerdns
    ipconfig /renew
    stop-service -force -ea 0 "dns client"
    start-service "dns client"
    netsh winsock reset all
    netsh int ip reset all
}
