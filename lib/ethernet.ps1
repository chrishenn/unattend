function set_staticip (
    [parameter(Mandatory = $false)][ValidateNotNullOrEmpty()] $IP = "192.168.1.40",
    [parameter(Mandatory = $false)][ValidateNotNullOrEmpty()] $MaskBits = 24,
    [parameter(Mandatory = $false)][ValidateNotNullOrEmpty()] $Gateway = "192.168.1.1",
    [parameter(Mandatory = $false)][ValidateNotNullOrEmpty()] $Dns = "192.168.1.49",
    [parameter(Mandatory = $false)][ValidateNotNullOrEmpty()] $IPType = "IPv4"
) {
    # assumes that there is only one interface that's up
    # Retrieve the network adapter that you want to configure
    $adapter = Get-NetAdapter | where-object {$_.Status -eq "up"}

    # Remove any existing IP, gateway from our ipv4 adapter
    if (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
        $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
    }
    if (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
        $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
    }

    # Configure the IP address and default gateway
    $adapter | New-NetIPAddress `
     -AddressFamily $IPType `
     -IPAddress $IP `
     -PrefixLength $MaskBits `
     -DefaultGateway $Gateway

    # Configure the DNS client server IP addresses
    $adapter | Set-DnsClientServerAddress -ServerAddresses $DNS
}

function enable_dhcp {
    # assumes that there is only one interface that's up
    $IPType = "IPv4"

    $adapter = Get-NetAdapter | ? {$_.Status -eq "up"}
    $interface = $adapter | Get-NetIPInterface -AddressFamily $IPType
    If ($interface.Dhcp -eq "Disabled") {
        # Remove existing gateway
        If (($interface | Get-NetIPConfiguration).Ipv4DefaultGateway) {
            $interface | Remove-NetRoute -Confirm:$false
        }
        # Enable DHCP
        $interface | Set-NetIPInterface -DHCP Enabled
        # Configure the DNS Servers automatically
        $interface | Set-DnsClientServerAddress -ResetServerAddresses
    }
}
