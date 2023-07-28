#!/bin/bash
exec 3>&1 4>&2

apt update
apt install pciutils patch flex bison libncurses-dev openssl libssl-dev dkms libelf-dev libudev-dev dwarves zstd bc wget python3-pip --yes
pip3 install git+https://github.com/a13xp0p0v/kconfig-hardened-check

kconfig-hardened-check -c /root/config-5.10.180-rt89-amd64 -l /proc/cmdline -m show_fail

wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.180.tar.xz
wget https://cdn.kernel.org/pub/linux/kernel/projects/rt/5.10/patch-5.10.180-rt89-rc1.patch.gz

cd /usr/src/
tar xf ~/linux-5.10.180.tar.xz
ln -s /usr/src/linux-5.10.180 /usr/src/linux
cd linux
gzip -cd /root/patch-5.10.180-rt89-rc1.patch.gz | patch -p1
cp /root/config-5.10.180-rt89-amd64 ./.config

make -j8
make -j8 modules_install
make -j8 install
nice make -j8 bindeb-pkg

update-initramfs -c -k 5.10.180-rt89

ln -s /boot/initrd.img-5.10.180-rt89-rc1 /boot/initrd.img
ln -s /boot/config-5.10.180-rt89-rc1 /boot/config
ln -s /boot/System.map-5.10.180-rt89-rc1 /boot/System.map
ln -s /boot/vmlinuz-5.10.180-rt89-rc1 /boot/vmlinuz

update-grub

cd /
cd /etc/selinux/
mkdir targeted
cd targeted/
mkdir contexts
cd contexts
touch ./.autorelabel

apt install policycoreutils selinux-basics
systemctl stop apparmor
apt remove appamror
