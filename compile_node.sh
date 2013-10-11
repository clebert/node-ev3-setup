#!/bin/bash

username=vagrant
nodeJS="$(wget -qO- http://nodejs.org/dist/latest/ | egrep -o 'node-v[0-9\.]+.tar.gz' | tail -1)"
sharedDir=/vagrant
targetDir="/home/$username"
target=node-linux-arm

InstallPrerequisites() {
    echo "############################"
    echo "# Installing prerequisites #"
    echo "############################"

    aptitude update
    aptitude -y install build-essential openssl libssl-dev pkg-config
}

InstallXToolsForARMv5() {
    echo "#########################################################"
    echo "# Installing pre-built crosstool-ng toolchain for ARMv5 #"
    echo "#########################################################"

    cd "$targetDir"
    cp "$sharedDir/x-tools.tar.xz" x-tools.tar.xz
    tar --extract --verbose --file=x-tools.tar.xz
    export PATH="$targetDir/x-tools/arm-unknown-linux-gnueabi/bin:$PATH"
}

DownloadNodeJS() {
    echo "#######################"
    echo "# Downloading Node.js #"
    echo "#######################"

    cd "$targetDir"
    wget -q "http://nodejs.org/dist/latest/$nodeJS"
    mkdir node
    tar --extract --verbose --gunzip --strip-components=1 --directory=node --file="$nodeJS"
}

BuildNodeJSForARMv5() {
    echo "##############################"
    echo "# Building Node.js for ARMv5 #"
    echo "##############################"

    export TOOL_PREFIX="arm-unknown-linux-gnueabi"
    export CC="${TOOL_PREFIX}-gcc"
    export CXX="${TOOL_PREFIX}-g++"
    export AR="${TOOL_PREFIX}-ar"
    export RANLIB="${TOOL_PREFIX}-ranlib"
    export LINK="${CXX}"
    export CCFLAGS="-march=armv5t -mfpu=softfp -marm"
    export CXXFLAGS="-march=armv5t -mno-unaligned-access"
    export OPENSSL_armcap=5
    export GYPFLAGS="-Darmeabi=soft -Dv8_can_use_vfp_instructions=false -Dv8_can_use_unaligned_accesses=false -Darmv7=0"
    export VFP3=off
    export VFP2=off

    sudo chown -R "$username": "$targetDir"
    cd "$targetDir/node"
    PREFIX_DIR=/usr
    ./configure --without-snapshot --dest-cpu=arm --dest-os=linux --prefix=$PREFIX_DIR
    make -j 2
    sudo chown -R "$username": "$targetDir"
    make install DESTDIR="$target"
    tar --create --verbose --file="$sharedDir/$target.tar" "$target"
}

DownloadNodeMMAP() {
    echo "#########################"
    echo "# Downloading node-mmap #"
    echo "#########################"

    cd "$targetDir"
    mkdir node_modules
    cd node_modules
    mkdir node-mmap
    cd node-mmap

    wget -q https://raw.github.com/clebert/node-mmap/master/package.json
    wget -q https://raw.github.com/clebert/node-mmap/master/binding.gyp
    wget -q https://raw.github.com/clebert/node-mmap/master/mmap.cc
}

BuildNodeJS() {
    echo "####################"
    echo "# Building Node.js #"
    echo "####################"

    sudo chown -R "$username": "$targetDir"
    cd "$targetDir/node"
    ./configure
    make -j 2
    sudo chown -R "$username": "$targetDir"
    make install
    npm install -g node-gyp
}

BuildNodeMMAPForARMv5() {
    echo "################################"
    echo "# Building node-mmap for ARMv5 #"
    echo "################################"

    export TOOL_PREFIX="arm-unknown-linux-gnueabi"
    export CC="${TOOL_PREFIX}-gcc"
    export CXX="${TOOL_PREFIX}-g++"
    export AR="${TOOL_PREFIX}-ar"
    export RANLIB="${TOOL_PREFIX}-ranlib"
    export LINK="${CXX}"
    export CCFLAGS="-march=armv5t -mfpu=softfp -marm"
    export CXXFLAGS="-march=armv5t -mno-unaligned-access"
    export OPENSSL_armcap=5
    export GYPFLAGS="-Darmeabi=soft -Dv8_can_use_vfp_instructions=false -Dv8_can_use_unaligned_accesses=false -Darmv7=0"
    export VFP3=off
    export VFP2=off

    cd "$targetDir/node_modules/node-mmap"

    node-gyp --arch=arm configure build

    cd "$targetDir"

    tar --create --verbose --file="$sharedDir/node-mmap.tar" node_modules
}

InstallPrerequisites
DownloadNodeJS
InstallXToolsForARMv5
BuildNodeJSForARMv5

#InstallPrerequisites
#DownloadNodeJS
#DownloadNodeMMAP
#BuildNodeJS
#InstallXToolsForARMv5
#BuildNodeMMAPForARMv5
