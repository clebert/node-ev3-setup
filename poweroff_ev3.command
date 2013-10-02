#!/bin/bash

ev3IP=$(node -e "process.stdout.write(require('$(dirname $0)/config.json').ev3IP);")

ssh root@"$ev3IP" poweroff
