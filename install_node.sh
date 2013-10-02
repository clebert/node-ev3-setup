#!/bin/bash

ev3IP=$(node -e "process.stdout.write(require('$(dirname $0)/config.json').ev3IP);")

Prepare() {
    echo "#############"
    echo "# Preparing #"
    echo "#############"

    if [ ! -e sysroot.tar ]; then
        tar --extract --verbose --file=x-tools.tar.xz
        cd x-tools/arm-unknown-linux-gnueabi/arm-unknown-linux-gnueabi
        tar --create --verbose --file=../../../sysroot.tar sysroot
        cd ../../../
        rm -Rf x-tools
    fi
}

Clean() {
    echo "############"
    echo "# Cleaning #"
    echo "############"

    ssh root@"$ev3IP" rm -f sysroot.tar
    ssh root@"$ev3IP" rm -Rf sysroot

    ssh root@"$ev3IP" rm -f node-linux-arm.tar
    ssh root@"$ev3IP" rm -Rf node-linux-arm
}

Copy() {
    echo "###########"
    echo "# Copying #"
    echo "###########"

    scp sysroot.tar root@"$ev3IP":"/home/root/sysroot.tar"
    scp node-linux-arm.tar root@"$ev3IP":"/home/root/node-linux-arm.tar"
}

Install() {
    echo "##############"
    echo "# Installing #"
    echo "##############"

    ssh root@"$ev3IP" tar -xvf sysroot.tar
    ssh root@"$ev3IP" cp -Rf sysroot/* /

    ssh root@"$ev3IP" tar -xvf node-linux-arm.tar
    ssh root@"$ev3IP" cp -Rf node-linux-arm/usr/* /usr
}

Prepare
Clean
Copy
Install
Clean
