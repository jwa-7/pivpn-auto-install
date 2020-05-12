#!/bin/bash

#Data
SCHEME="https"
PULL_URL="install.pivpn.io"
PULL_URL="raw.githubusercontent.com/pivpn/pivpn/master/auto_install/install.sh"
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALLERFILES_PATH="./installer-files/"
PULLED_SCRIPT="official-install-script.sh"
OPTIONS_FILE="options.conf"

#-------------------------

echo "! Run with sudo !"


#!--- PiVPN Part
echo "** Automated PiVPN-Installer **"
echo "Data in '$INSTALLERFILES_PATH$OPTIONS_FILE'"

mkdir -p $INSTALLERFILES_PATH

FILE=$INSTALLERFILES_PATH$OPTIONS_FILE
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist. Aborting..."
    
else
    
    echo "$FILE exist. Continue..."
    
    apt-get update -y && apt-get upgrade -y
    
    echo "Pulling PiVPN Install-Script from $PULL_URL"
    curl -L $SCHEME://$PULL_URL > $INSTALLERFILES_PATH$PULLED_SCRIPT
    chmod +x $INSTALLERFILES_PATH$PULLED_SCRIPT
    echo "Using $OPTIONS_FILE:"
    echo $(cat $INSTALLERFILES_PATH$OPTIONS_FILE)
    
    . $INSTALLERFILES_PATH$PULLED_SCRIPT --unattended $INSTALLERFILES_PATH$OPTIONS_FILE
    
    
    #If PiVPN Installer doesn't add iptables config:
    # iptables -A INPUT -i eth0 -m state --state NEW -p udp --dport 1194 -j ACCEPT
    #
    # iptables -A INPUT -i tun+ -j ACCEPT
    #
    # iptables -A FORWARD -i tun+ -j ACCEPT
    # iptables -A FORWARD -i tun+ -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    # iptables -A FORWARD -i eth0 -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT
    #
    # iptables -t nat -A POSTROUTING -s 10.8.0.1/24 -o eth0 -j MASQUERADE
    #
    # iptables -A OUTPUT -o tun+ -j ACCEPT
    
    
    
    #Change udp -> udp6
    echo "Changing protcol from 'udp' to 'udp6'"
    #Serverconf /etc/openvpn/server.conf
    sed -i 's/proto udp/proto udp6/' /etc/openvpn/server.conf
    #todo change redirect-gateway def1 to redirect-gateway
    echo "Updated 'server.conf'"
    #Client template /etc/openvpn/easy-rsa/pki/Default.txt
    sed -i 's/proto udp/proto udp6/' /etc/openvpn/easy-rsa/pki/Default.txt
    echo "Updated client-template 'Default.txt'"
    
    #OpenVPN Management
    # OVPN_MGMT="127.0.0.1 9786"
    # echo "Setting up OpenVPN Management on OVPN_MGMT"
    # sudo bash -c "echo \"management $OVPN_MGMT\" >> /etc/openvpn/server.conf"
    
    # echo "To use the management connect to it via 'nc $OVPN_MGMT'"
    # echo "use 'kill <CLIENTNAME>' to kick a connected client"
    # echo "Exit nc/management with CTRL+C"
    
    #! DDNS-Part
    
    
    dynv6folder="dynv6"
    
    cd $SCRIPTDIR
    chmod +x *.sh
    cd $dynv6folder
    chmod +x *.sh
    cd ../
    
    echo "Updating Dynv6 DDNS IPv6..."
    bash $dynv6folder/update--force.sh
    
    echo "Adding update service to crontab..."
    crontab -l > cron_tmpfile
    #echo new cron into cron file
    echo "*/5 * * * * /bin/bash -c \"$SCRIPTDIR/$dynv6folder/update.sh\"" >> cron_tmpfile
    #install new cron file
    crontab cron_tmpfile
    rm cron_tmpfile
    service cron reload
    
    echo "Check your crontab entries with 'sudo crontab -l'"
    
    
    echo "You should now check the port-forwarding in your router!"
    echo "You should also reboot your Raspberry Pi"
    echo "After reboot check isntall status with 'pivpn -d'"
fi
echo "END OF LINE."