#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

sourcefile="$SCRIPTDIR/dynv6.conf"
source "${sourcefile}"

sudo rm -f $SCRIPTDIR/dynv6.addr6
sudo token=$token $SCRIPTDIR/dynv6.sh $hostnamezone