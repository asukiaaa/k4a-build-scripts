#!/bin/bash

# crate directory for deb file
WORK_DIR=$(realpath ~/debprojects/k4a/work)
rm -r $WORK_DIR
mkdir -p ${WORK_DIR}/DEBIAN
OUTPUT_DEB_DIR=$(reaplath $WORK_DIR/../)

# build and put sdk
mkdir -p ~/gitprojects
cd ~/gitprojects
git clone -b support-ubuntu-22.04 https://github.com/asukiaaa/Azure-Kinect-Sensor-SDK.git
cd ~/gitprojects/Azure-Kinect-Sensor-SDK
rm -r build
mkdir build
cd build
cmake .. -GNinja -DCMAKE_INSTALL_PREFIX=$WORK_DIR/usr/local
ninja install

# get depth engine from avairable deb file
cd /tmp
wget https://packages.microsoft.com/ubuntu/18.04/prod/pool/main/libk/libk4a1.4/libk4a1.4_1.4.1_amd64.deb
ar vx libk4a1.4_1.4.1_amd64.deb
tar xvf data.tar.gz
cp usr/lib/x86_64-linux-gnu/libk4a1.4/libdepthengine.so.2.0 $WORK_DIR/usr/local/lib/

# put udev rules
UDEV_DIR=$WORK_DIR/etc/udev/rules.d
mkdir -p $UDEV_DIR
wget https://raw.githubusercontent.com/microsoft/Azure-Kinect-Sensor-SDK/develop/scripts/99-k4a.rules -P $UDEV_DIR

# create control file
FILE_CONTROL=$WORK_DIR/DEBIAN/control
echo "Package: libk4a1.4
Version: 1.4.1
Section: devel
Priority: optional
Architecture: amd64
Depends: libc6 (>= 2.27), libgcc1 (>= 1:3.0), libgl1, libstdc++6 (>= 7), libudev1 (>= 183), libx11-6
Pre-Depends: debconf (>= 0.2.17)
Maintainer: Microsoft
Description: Dynamic Libraries for Azure Kinect Runtime" >> $FILE_CONTROL

# build deb file
dpkg-deb --build $WORK_DIR $OUTPUT_DEB_DIR

# $OUTPUT_DEB_DIR/libk4a1.4_1.4.1_amd64.deb is that!
