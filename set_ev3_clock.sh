#!/bin/bash

ev3IP=$(node -e "process.stdout.write(require('$(dirname $0)/config.json').ev3IP);")

setSystemTime() {
    echo "#############################"
    echo "# Setting System Time (UTC) #"
    echo "#############################"

    date=$(date -u "+%Y.%m.%d-%H:%M:%S")

    ssh root@"$ev3IP" date -u -s "$date"
}

setHardwareClock() {
    echo "################################"
    echo "# Setting Hardware Clock (UTC) #"
    echo "################################"

    ssh root@"$ev3IP" hwclock -u -w
    ssh root@"$ev3IP" hwclock -u -r
}

setSystemTime
setHardwareClock
