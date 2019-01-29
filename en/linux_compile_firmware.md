# Compiling Linux Firmware

In this chapter, we'll walk through the steps of compiling Linux firmware for [ROC-RK3328-CC].

## Preparation

The Linux firmware is built under the following environment:

- Debian 9 amd64

Install following packages:

``` shell
sudo apt-get install bc bison build-essential curl \
     device-tree-compiler dosfstools flex gcc-aarch64-linux-gnu \
     gcc-arm-linux-gnueabihf gdisk git gnupg gperf libc6-dev \
     libncurses5-dev libpython-dev libssl-dev libssl1.0.2 \
     lzop mtools parted swig tar zip python-kerberos
```
Install repo manually
wget http://ftp.us.debian.org/debian/pool/contrib/r/repo/repo_1.12.37-3_all.deb
sudo dpkg -i repo_1.12.37-3_all.deb

## Download the Linux SDK

Create the project directory:

``` shell
# create project dir
mkdir -p ~/proj/roc-rk3328-cc
cd ~/proj/roc-rk3328-cc
```

Download the Linux SDK:

``` shell
# U-Boot
git clone -b roc-rk3328-cc https://github.com/FireflyTeam/u-boot
# Kernel
git clone -b roc-rk3328-cc https://github.com/FireflyTeam/kernel --depth=1
# Build
git clone -b debian https://github.com/FireflyTeam/build
# Rkbin
git clone -b master https://github.com/FireflyTeam/rkbin
```

You can also browse the source code online using the github links above.

The board building config is within:

    build/board_configs.sh

## Compiling U-Boot

Compile U-Boot:

``` shell
./build/mk-uboot.sh roc-rk3328-cc
```

Ouput:

```text
out/u-boot/
├── idbloader.img
├── rk3328_loader_ddr786_v1.06.243.bin
├── trust.img
└── uboot.img
```

- `rk3328_loader_ddr786_v1.06.243.bin`: A DDR init bin.
- `idbloader.img`: Image combined with DDR init bin and miniloader bin.
- `trust.img`: ARM trusted firmware.
- `uboot.img`: U-Boot image.

Related files:

- `configs/roc-rk3328-cc_defconfig`: default U-Boot config

## Compiling Kernel

Compile kernel:

``` shell
./build/mk-kernel.sh roc-rk3328-cc
```

Ouput:

```text
out/
├── boot.img
└── kernel
    ├── Image
    └── rk3328-roc-cc.dtb
```

- `boot.img`: A image file containing `Image` and `rk3328-roc-cc.dtb`, in fat32 filesystem format.
- `Image`: Kernel image.
- `rk3328-roc-cc.dtb`: Device tree blob.

Related files:

- `arch/arm64/configs/fireflyrk3328_linux_defconfig`: default kernel config
- `arch/arm64/boot/dts/rockchip/rk3328-roc-cc.dts`: board dts
- `arch/arm64/boot/dts/rockchip/rk3328.dtsi`: soc dts

To customize the kernel config and update the default config:

``` shell
# this is important!
export ARCH=arm64

cd kernel

# first use default config
make fireflyrk3328_linux_defconfig

# customize your kernel
make menuconfig

# save as default config
make savedefconfig
cp defconfig arch/arm64/configs/fireflyrk3328_linux_defconfig
```

**NOTE**: The build script does not copy kernel modules to the root filesystem. You have to do it yourself.

## Building Root Filesystem

You can download the prebuilt root filesystem or build one yourself by following [Building Linux Root Filesystem].

## Packing Raw Format Firmware

Place your Linux root filesystem image file as `out/rootfs.img`.

The `out` directory should contain the following files:

```text
$ tree out
out
├── boot.img
├── kernel
│   ├── Image
│   └── rk3328-roc-cc.dtb
├── rootfs.img
└── u-boot
    ├── idbloader.img
    ├── rk3328_loader_ddr786_v1.06.243.bin
    ├── trust.img
    └── uboot.img

2 directories, 8 files
```

To create the [Raw Firmare]:

``` shell
./build/mk-image.sh -c rk3328 -t system -r out/rootfs.img
```

The command above will pack the neccessary image files into `out/system.img`, according to this [Storage Map].

To flash this [Raw Firmware], please follow the [Getting Started] chapter.

[Getting Started]: started.md
[FAQ]: faq.md
[Serial Debug]: debug.md
[Building Linux Root Filesystem]: linux_build_rootfilesystem.md
[Contact]: resource.md#community
[Raw Firmware]: started.md#raw-firmware-format
[RK Firmware]: started.md#rk-firmware-format
[Partition Image]: started.md#partition-image
[SDCard Installer]: flash_sd.md#sdcard-installer
[Etcher]: flash_sd.md#etcher
[dd]: flash_sd.md#dd
[SD Firmware Tool]: flash_sd.md#sd-firmware-tool
[AndroidTool]: flash_emmc.md#androidtool
[upgrade_tool]: flash_emmc.md#upgrade-tool
[rkdeveloptool]: flash_emmc.md#rkdeveloptool
[Rockusb Mode]: flash_emmc.md#rockusb-mode
[Maskrom Mode]: flash_emmc.md#maskrom-mode
[Rockusb Driver]: flash_emmc.md#rockusb-driver
[ROC-RK3328-CC]: http://en.t-firefly.com/product/rocrk3328cc.html "ROC-RK3328-CC Official Website"
[Download Page]: http://en.t-firefly.com/doc/download/34.html
[Forum]: http://bbs.t-firefly.com/
[Facebook]: https://www.facebook.com/TeeFirefly
[Google+]: https://plus.google.com/u/0/communities/115232561394327947761
[Youtube]: https://www.youtube.com/channel/UCk7odZvUrTG0on8HXnBT7gA
[Twitter]: https://twitter.com/TeeFirefly
[Shop]: http://shop.t-firefly.com/
[USB Serial Adapter]: http://shop.t-firefly.com/goods.php?id=32
[5V2A US Adapter]: http://shop.t-firefly.com/goods.php?id=68
[eMMC Flash]: http://shop.t-firefly.com/goods.php?id=69
[Storage Map]: http://opensource.rock-chips.com/wiki_Partitions#Default_storage_map
