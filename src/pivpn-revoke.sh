#!/bin/bash

#With openvpn-management
# pivpn list
# OVPN_MGMT="127.0.0.1 9786"
# echo "To use the management connect to it via 'nc $OVPN_MGMT'"
# echo "use 'kill <CLIENTNAME>' to kick a connected client"
# echo "Exit nc/management with CTRL+C"




echo "Use 'pivpn revoke' to remove certificates"

pivpn revoke

sudo systemctl stop openvpn
sleep 2s
sudo systemctl start openvpn

echo "Please reboot now..."