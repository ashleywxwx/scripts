#!/bin/sh
# Modified from https://www.kittell.net/code/mac-os-x-get-network-information/

sExternalMACALService="http://dns.kittell.net/macaltext.php?address="

# List all Network ports
NetworkPorts=$(ifconfig -uv | grep '^[a-z0-9]' | awk -F : '{print $1}')
#echo $NetworkPorts

# Get remote/public IP address
remoteip=$(dig +short myip.opendns.com @resolver1.opendns.com)

echo "External"
echo "--------------"
if [[ $remoteip ]]; then
    echo "Remote IP    :  $remoteip\n"
else
    echo "Remote IP    :  Unable To Determine\n"
fi

for val in $(echo $NetworkPorts); do   # Get for all available hardware ports their status
    activated=$(ifconfig -uv "$(echo $val)" | grep 'status: ' | awk '{print $2}')
    #echo $activated

    if [ "$activated" == "active" ]; then
        label=$(ifconfig -uv "$(echo $val)" | grep 'type' | awk '{print $2}')
        #echo $label
        #ActiveNetwork=$(route get default | grep interface | awk '{print $2}')
        ActiveNetworkName=$(networksetup -listallhardwareports | grep -B 1 "$label" | awk '/Hardware Port/{ print }'|cut -d " " -f3- | uniq)
        #echo $ActiveNetwork
        #echo $ActiveNetworkName
        state=$(ifconfig -uv "$val" | grep 'status: ' | awk '{print $2}')
        #echo $state
        ipaddress=$(ifconfig -uv "$val" | grep 'inet ' | awk '{print $2}')
        # echo $ipaddress

        if [[ -z $(ifconfig -uv "$val" | grep 'link rate: ' | awk '{print $3, $4}' | sed 'N;s/\n/ up /' ) ]]; then
            networkspeed="$(ifconfig -uv "$val" | grep 'link rate: ' | awk '{print $3, $4}' ) up/down"
        else
            networkspeed="$(ifconfig -uv "$val" | grep 'link rate: ' | awk '{print $3, $4}' | sed 'N;s/\n/ up \\n                /' ) down"
        fi

        #echo $networkspeed
        macaddress=$(ifconfig -uv "$val" | grep 'ether ' | awk '{print $2}')
        #echo $macaddress
        macal=$(curl -s "$sExternalMACALService$macaddress")
        #echo $macal
        quality=$(ifconfig -uv "$val" | grep 'link quality:' | awk '{print $3, $4}')
        #echo $quality
        netmask=$(ipconfig getpacket "$val" | grep 'subnet_mask (ip):' | awk '{print $3}' | tr -d '[:space:]')
        #echo $netmask
        router=$(ipconfig getpacket "$val" | grep 'router (ip_mult):' | sed 's/.*router (ip_mult): {\([^}]*\)}.*/\1/')
        #echo $router
        DHCPActive=$(networksetup -getinfo "Wi-Fi" | grep DHCP)
        #echo $DHCPActive
        dnsserver=$(networksetup -getdnsservers "$ActiveNetworkName" | awk '{print $1, $2}' | sed 'N;s/\n//' )
        #echo $dnsserver

        if [[ ! -z "$netmask" ]]; then
            if [[ $ipaddress ]]; then
                echo "$(echo $ActiveNetworkName | awk '{print $1}') ($val)"
                echo "--------------"

                # Is this a WiFi associated port? If so, then we want the network name
                if [ "$label" = "Wi-Fi" ]; then
                    WiFiName=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I | grep '\sSSID:' | sed 's/.*: //')
                    #echo $WiFiName
                    echo "     Network Name:  $WiFiName"
                fi

                echo "   IP Address:  $ipaddress"
                echo "       Router:  $router"

                if [[ -z $dnsserver ]]; then
                    if [[ $DHCPActive ]]; then
                        echo "   DNS Server:  Set With DHCP"
                    else
                        echo "   DNS Server:  Unknown"
                    fi
                else
                    echo "   DNS Server:  $dnsserver"
                fi

                echo "  MAC-address:  $macaddress"
                echo "Network Speed:  $networkspeed"
                echo " Link quality:  $quality"
                echo " "
            fi

            # Don't display the inactive ports.
        fi
    fi
done
