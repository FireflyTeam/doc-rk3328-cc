# 编译 Debian 根文件系统

## 准备编译系统

``` shell
git clone https://github.com/FireflyTeam/rk-rootfs-build.git
cd rk-rootfs-build
sudo apt-get install binfmt-support qemu-user-static
sudo dpkg -i ubuntu-build-service/packages/*
sudo apt-get install -f
```

## 编译根文件系统

1. 编译基础 Debian 系统：

    ``` shell
    VERSION=stretch TARGET=desktop ARCH=armhf ./mk-base-debian.sh
    ```

    上述命令会调用 `live-build` 去生成一个基本的 Debian Stretch 桌面系统，并打包到文件 `linaro-stretch-alip-*.tar.gz` 中。此操作比较耗时，除非修改了 `live-build` 的配置文件，一般只需要运行一次。

2. 编译 rk-debian 系统：
    ``` shell
    VERSION=stretch TARGET=desktop ARCH=armhf ./mk-rootfs.sh
    ```

    该命令会先解压基础 Debian 系统文件 `linaro-stretch-alip-*.tar.gz` ，在此基础上安装和设置 Rockchip 的相关组件，例如 mali、视频解码等，最终生成完整的 rk-debian 系统。

3. 创建 ext4 映像文件 `linaro-rootfs.img`：

    ``` shell
    ./mk-image.sh
    ```

注意：默认的用户和密码均为 ”linaro“。

# 编译 Ubuntu 根文件系统

环境：

- Ubuntu 16.04 amd64

安装依赖包：

``` shell
sudo apt-get install qemu qemu-user-static binfmt-support debootstrap
```

下载 Ubuntu core：

``` shell
wget -c http://cdimage.ubuntu.com/ubuntu-base/releases/16.04.1/release/ubuntu-base-16.04.1-base-arm64.tar.gz
```

创建一个大小为 1000M 的根文件系统映像文件，并使用 Ubuntu 的基础包去初始化：

``` shell
fallocate -l 1000M rootfs.img
sudo mkfs.ext4 -F -L ROOTFS rootfs.img
mkdir mnt
sudo mount rootfs.img mnt
sudo tar -xzvf ubuntu-base-16.04.1-base-arm64.tar.gz -C mnt/
sudo cp -a /usr/bin/qemu-aarch64-static mnt/usr/bin/
```

`qemu-aarch64-static`是其中的关键，能在 x86_64 主机系统下 chroot 到 arm64 文件系统：

Chroot 到新的文件系统中去并初始化：

``` shell
sudo chroot mnt/

# 这里可以修改设置
USER=firefly
HOST=firefly

# 创建用户
useradd -G sudo -m -s /bin/bash $USER
passwd $USER
# 输入密码

# 设置主机名和以太网
echo $HOST > /etc/hostname
echo "127.0.0.1    localhost.localdomain localhost" > /etc/hosts
echo "127.0.0.1    $HOST" >> /etc/hosts
echo "auto eth0" > /etc/network/interfaces.d/eth0
echo "iface eth0 inet dhcp" >> /etc/network/interfaces.d/eth0
echo "nameserver 127.0.1.1" > /etc/resolv.conf

# 使能串口
ln -s /lib/systemd/system/serial-getty\@.service /etc/systemd/system/getty.target.wants/serial-getty@ttyS0.service

# 安装包
apt-get update
apt-get upgrade
apt-get install ifupdown net-tools network-manager
apt-get install udev sudo ssh
apt-get install vim-tiny
```

卸载文件系统：

``` shell
sudo umount rootfs/
```

Credit： [bholland](https://forum.armbian.com/topic/6850-document-about-compiling-a-kernel-and-rootfs-for-the-firefly-boards/)

## 参考

- [http://opensource.rock-chips.com/wiki_Distribution](http://opensource.rock-chips.com/wiki_Distribution)
