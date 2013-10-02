#!/bin/bash

username=root
ev3IP=192.168.178.28

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

    ssh "$username"@"$ev3IP" rm -f sysroot.tar
    ssh "$username"@"$ev3IP" rm -Rf sysroot

    ssh "$username"@"$ev3IP" rm -f node-linux-arm.tar
    ssh "$username"@"$ev3IP" rm -Rf node-linux-arm
}

Copy() {
    echo "###########"
    echo "# Copying #"
    echo "###########"

    scp sysroot.tar "$username"@"$ev3IP":"/home/$username/sysroot.tar"
    scp node-linux-arm.tar "$username"@"$ev3IP":"/home/$username/node-linux-arm.tar"
}

Install() {
    echo "##############"
    echo "# Installing #"
    echo "##############"

    ssh "$username"@"$ev3IP" tar -xvf sysroot.tar
    ssh "$username"@"$ev3IP" cp -Rf sysroot/* /

    ssh "$username"@"$ev3IP" tar -xvf node-linux-arm.tar
    ssh "$username"@"$ev3IP" cp -Rf node-linux-arm/usr/* /usr
}

Prepare
Clean
Copy
Install
Clean
