#!/bin/bash

BASEDIR=$(dirname $0)
source $BASEDIR/lib/trackers

echo "Launching trackWithExit in a subshell"
trackWithExit &
echo "trackWithExit has been launched successfully"

echo "Launching trackWithReturn in a subshell"
trackWithReturn &
echo "trackWithReturn has been launched successfully"

i=0
TIMEOUT=100
while :
do
    if [ $i -gt $TIMEOUT ]; then
        break
    else
        echo "Main process working..."
        sleep 1
        ((i++))
    fi
done
