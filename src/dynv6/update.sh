#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

sourcefile="$SCRIPTDIR/dynv6.conf"
source "${sourcefile}"

sudo token=$token $SCRIPTDIR/dynv6.sh $hostnamezone