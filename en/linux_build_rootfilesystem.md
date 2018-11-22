# Building Debian Root Filesystem

## Preparing Build System

```shell
git clone https://github.com/FireflyTeam/rk-rootfs-build.git
cd rk-rootfs-build
sudo apt-get install binfmt-support qemu-user-static
sudo dpkg -i ubuntu-build-service/packages/*
sudo apt-get install -f
```

## Compile the Root File System

1. Build the Debian basic system:

    ``` shell
    VERSION=stretch TARGET=desktop ARCH=armhf ./mk-base-debian.sh
    ```

    This will use `live-build` to create a basic Debian Stretch desktop system, which is later packed as file `linaro-stretch-alip-*.tar.gz`. This operation takes time and only needs to run once unless you have modified the `live-build` configuration.

2. Build the rk-debian system:
    ``` shell
    VERSION=stretch TARGET=desktop ARCH=armhf ./mk-rootfs.sh
    ```

    This will install/setup Rockchip components such as mali and video encode/decode, based on the `linaro-stretch-alip-*.tar.gz` file from previous step, to create the full rk-debian system.

3. Create the ext4 image file `linaro-rootfs.img`:

    ``` shell
    ./mk-image.sh
    ```

Note: default user and password is "linaro".

# Building Ubuntu Root Filesystem

Environment:

- Ubuntu 16.04 amd64

Install required packages:

```shell
sudo apt-get install qemu qemu-user-static binfmt-support debootstrap
```

Download Ubuntu core:

```shell
wget -c http://cdimage.ubuntu.com/ubuntu-base/releases/16.04.1/release/ubuntu-base-16.04.1-base-arm64.tar.gz
```

Create a root filesystem image file sized 1000M and populate it with the ubuntu base tar file:

```shell
fallocate -l 1000M rootfs.img
sudo mkfs.ext4 -F -L ROOTFS rootfs.img
mkdir mnt
sudo mount rootfs.img mnt
sudo tar -xzvf ubuntu-base-16.04.1-base-arm64.tar.gz -C mnt/
sudo cp -a /usr/bin/qemu-aarch64-static mnt/usr/bin/
```

`qemu-aarch64-static` is the magic cure here, which make possible chrooting into an Arm64 filesystem under x86_64 host system.

Chroot to the new filesystem and initialize:

```shell
sudo chroot mnt/

# Change the setting here
USER=firefly
HOST=firefly

# Create User
useradd -G sudo -m -s /bin/bash $USER
passwd $USER
# enter user password

# Hostname & Network
echo $HOST > /etc/hostname
echo "127.0.0.1    localhost.localdomain localhost" > /etc/hosts
echo "127.0.0.1    $HOST" >> /etc/hosts
echo "auto eth0" > /etc/network/interfaces.d/eth0
echo "iface eth0 inet dhcp" >> /etc/network/interfaces.d/eth0
echo "nameserver 127.0.1.1" > /etc/resolv.conf

# Enable serial console
ln -s /lib/systemd/system/serial-getty\@.service /etc/systemd/system/getty.target.wants/serial-getty@ttyS0.service

# Install packages
apt-get update
apt-get upgrade
apt-get install ifupdown net-tools network-manager
apt-get install udev sudo ssh
apt-get install vim-tiny
```

Unmount filesystem:

```shell
sudo umount rootfs/
```

Credit: [bholland](https://forum.armbian.com/topic/6850-document-about-compiling-a-kernel-and-rootfs-for-the-firefly-boards/)

## Reference

- [http://opensource.rock-chips.com/wiki_Distribution](http://opensource.rock-chips.com/wiki_Distribution)
