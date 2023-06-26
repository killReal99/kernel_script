#!/bin/bash
exec 3>&1 4>&2

apt install pciutils patch flex bison libncurses-dev openssl libssl-dev dkms libelf-dev libudev-dev dwarves zstd bc wget pyhon3-pip --yes

wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.180.tar.xz
wget https://cdn.kernel.org/pub/linux/kernel/projects/rt/5.10/patch-5.10.180-rt89-rc1.patch.gz

cd /usr/src/
tar xf ~/linux-5.10.180.tar.xz
ln -s /usr/src/linux-5.10.180 /usr/src/linux
cd linux
gzip -cd /root/patch-5.10.180-rt89-rc1.patch.gz | patch -p1
cp /root/config-5.10.180-rt89-amd64 ./.config

make -j8
make modules_install
make install
nice make -j8 bindeb-pkg

update-initramfs -c -k 5.10.180-rt89

ln -s /boot/initrd.img-5.10.180-rt89 /boot/initrd.img
ln -s /boot/config-5.10.180-rt89 /boot/config
ln -s /boot/System.map-5.10.180-rt89 /boot/System.map
ln -s /boot/vmlinuz-5.10.180-rt89 /boot/vmlinuz

update-grub
