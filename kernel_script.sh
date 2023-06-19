#!/bin/bash
exec 3>&1 4>&2

apt install pciutils patch flex bison libncurses-dev openssl libssl-dev dkms libelf-dev libudev-dev dwarves zstd bc

wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.180.tar.xz
wget https://cdn.kernel.org/pub/linux/kernel/projects/rt/5.10/patch-5.10.180-rt89-rc1.patch.gz

cd /usr/src/
tar xf ~/linux-5.10.180.tar.xz
ln -s /usr/src/linux-5.10.180 /usr/src/linux
cd linux
gzip -cd ~/patch-5.10.180-rt89-rc1.patch.gz | patch -p1
cp /root/config.5-10.180-rt89-amd64 ./.config

make -j8
make modules_install
make install
nice make -j8 bindeb-pkg