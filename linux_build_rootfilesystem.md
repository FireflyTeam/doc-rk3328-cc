# Building Debian Root Filesystem

## Preparing Build System
```bash
git clone https://github.com/FireflyTeam/rk-rootfs-build.git
cd rk-rootfs-build
sudo apt-get install binfmt-support qemu-user-static
sudo dpkg -i ubuntu-build-service/packages/*
sudo apt-get install -f
```

## Compile the Root File System

Build a basic Debian system using the ubuntu-build-service:
```bash
VERSION=stretch TARGET=desktop ARCH=armhf ./mk-base-debian.sh
```

# Building Ubuntu Root Filesystem

Environment:

- Ubuntu 16.04 64 bit

Install required packages:

    sudo apt-get install qemu qemu-user-static binfmt-support debootstrap

Download Ubuntu core:

    wget -c http://cdimage.ubuntu.com/ubuntu-base/releases/16.04.1/release/ubuntu-base-16.04.1-base-arm64.tar.gz

Create a root filesystem image file sized 1000M and populate it with the ubuntu base tar file:

    fallocate -l 1000M rootfs.img
    sudo mkfs.ext4 -F ROOTFS rootfs.img 
    mkdir mnt 
    sudo mount rootfs.img mnt
    sudo tar -xzvf ubuntu-base-16.04.1-base-arm64.tar.gz -C mnt/
    sudo cp -a /usr/bin/qemu-aarch64-static mnt/usr/bin/

`qemu-aarch64-static` is the magic cure here, which enables chroot into an arm64 filesystem under amd64 host system.

Chroot to the new filesystem and initialize:

    sudo chroot mnt/

    # Change the setting here
    USER=firefly
    HOST=firefly

    # Create User
    useradd -G sudo -m -s /bin/bash $USER
    passwd $USER
    # enter user password
    
    # Hostname & Network
    echo $HOST /etc/hostname
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

Unmount filesystem:

    sudo umount rootfs/

Credit: [bholland](https://forum.armbian.com/topic/6850-document-about-compiling-a-kernel-and-rootfs-for-the-firefly-boards/)

## Reference
 - [http://opensource.rock-chips.com/wiki_Distribution](http://opensource.rock-chips.com/wiki_Distribution)
