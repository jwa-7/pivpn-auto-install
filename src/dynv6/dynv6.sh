#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
hostname=$1
device=$2
file="$SCRIPTDIR/dynv6.addr6"


[ -e $file ] && old=`cat $file`

echo ""

if [ -z "$hostname" -o -z "$token" ]; then
  echo "Usage: token=<your-authentication-token> [netmask=64] $0 your-name.dynv6.net [device]"
  echo "Usually: token=abc123abc123 ./dynv6.sh myzone.dynv6.net"
  exit 1
fi

if [ -z "$netmask" ]; then
  netmask=128
fi

if [ -n "$device" ]; then
  device="dev $device"
fi
address=$(ip -6 addr list scope global $device | grep -v " fd" | sed -n 's/.*inet6 \([0-9a-f:]\+\).*/\1/p' | head -n 1)

if [ -e /usr/bin/curl ]; then
  bin="curl -fsS"
elif [ -e /usr/bin/wget ]; then
  bin="wget -O-"
else
  echo "neither curl nor wget found"
  exit 1
fi

if [ -z "$address" ]; then
  echo "no IPv6 address found"
  exit 1
fi

# address with netmask
current=$address/$netmask

if [ "$old" = "$current" ]; then
  echo "IPv6 address unchanged"
  exit
fi

# send v6 address to dynv6
#$bin "http://ipv6.dynv6.com/api/update?hostname=$hostname&ipv6=$current&token=$token"
$bin "http://ipv6.dynv6.com/api/update?hostname=$hostname&ipv6=auto&token=$token"

# save current address
echo $current > $file