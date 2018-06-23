# Flashing to the eMMC

## Boot Mode

eMMC flash is commonly soldered directly to the board. Some eMMC flash are pluggable, but it is hard to find a reader to use on PC. Therefore, eMMC is generally flashed onboard, that is, running to tiny system on the obard, which reads firmware data from PC and flashes to eMMC.

Depending on the existing data on the eMMC flash, there are two special boot modes: [Rockusb Mode] and [Maskrom Mode].

You usually just need to enter [Rockusb Mode] for upgrading an existing Android OS or Firefly Ubuntu OS, which is packed with [RK Firmware] format.

[Maskrom Mode] is the last resort when [Rockusb Mode] is not available due to bootloader damage, or you need to flash [Raw Firmware] to eMMC.

### Rockusb Mode

If the board powers on and finds a valid IDB (IDentity Block) in the eMMC, it will continue to load the bootloader from the eMMC and pass execution control to it. If the bootloader checks that the Recovery button is pressed and USB connection is made, then it enters the so-called [Rockusb Mode], waiting for further instructions from the host.

Requirement:

- 5V2A power adapter.
- Micro USB cable to connect power adapter and board.
- Male to male USB cable to connect host PC and board.
- eMMC.

Steps:

1. Pull all the USB cables (including micro USB cable and male to male USB cable) out of the board, to keep the board powering off.
2. Install the eMMC and pull out the SD card.
3. Use the male to male USB cable to connect the host PC with the USB 2.0 OTG port (the lower one in the double-decker ports) of the board.

    ![](img/hw_board_usbconn.png)

4. Keep the RECOVERY button on the board pressed.
5. Plug in the micro USB cable to the board to power up.
6. Wait about 3 seconds before releasing the RECOVERY button.

### Maskrom Mode

If anyone of the following conditions is met when the board powers on:

- eMMC is empty.
- The bootloader on eMMC is damaged.
- eMMC read data failed by connecting eMMC data/clock pin to ground.

then no valid IDB (IDentity Block) will be found in the eMMC. The CPU will execute a small ROM code, waiting for the host to upload via USB a small DDR blob to initialize the DDR memory, and later a full bootloader to handle further firmware upgrading. This mode is called [Maskrom Mode].

It involves hardware operation to force into [MaskRom Mode], which has certain risk and should be carried out **VERY CAREFULLY**.

Requirement:

- 5V2A power adapter.
- Micro USB cable to connect power adapter and board.
- Male to male USB cable to connect host PC and board.
- Metal tweezers to connect eMMC clock pin to ground.
- eMMC.

Steps:

1. Pull all the USB cables (including micro USB cable and male to male USB cable) out of the board, to keep the board power off.
2. Install the eMMC and pull out the SD card.
3. Use a male to male USB cable to connect your host PC and USB OTG port of the board:

    ![](img/hw_board_usbconn.png)

4. Find the reserved eMMC CLK and GND pads on the board, as shown below:

    ![](img/rk3328_maskrom_pads.jpg)

5. Connect the eMMC CLK and GND pads with metal tweezers and keep holding steadily.
6. Plug in the micro USB cable to the board to power on.
7. Wait about 1 seconds before releasing the metal tweezers.

## Flashing Tools

Please use the eMMC flashing tools according to your OS:

- To flash to the eMMC:
    + GUI
        * [AndroidTool] (Windows)
    + CLI
        * [upgrade_tool] (Linux)
        * [rkdeveloptool] (Linux)

## AndroidTool

[AndroidTool] is used to flash [Raw Firmware], [RK Firmware] and [Partition Image] to eMMC.

To use [AndroidTool], you need to [install Rockusb Driver] first.

<span id="install-rockusb-driver"></span>

### Installing Rockusb Driver

Download [DriverAssistant](https://pan.baidu.com/s/1migPY1U#list/path=%2FPublic%2FDevBoard%2FROC-RK3328-CC%2FTools%2FRKTools%2Fwindows&parentPath=%2FPublic%2FDevBoard%2FROC-RK3328-CC
), extract the archive and run `DriverInstall.exe` inside.

![](img/started_driverassistant.png)

Click the "驱动安装" button to install the driver. If you want to uninstall the driver, click the "驱动卸载" button.

If your device is in [Rockusb Mode] or [Maskrom Mode], you'll find a `Rockusb Device` in the device manager:

![](img/started_driverassistant_dev.png)

### Installing AndroidTool

> [AndroidTool Download Page](http://www.t-firefly.com/share/index/listpath/id/acd8e1e37176fba5bf61fb7bf4503998.html)

Download [AndroidTool], extract it. Locate the file named `config.ini`, and edit it by changing the 4th line from `Selected=1` to `Selected=2`, in order to select English as the default user interface language.

Launch `AndroidTool.exe`:

![](img/androidtool.png)

If your device is in [Rockusb Mode], the status line will be "Found One LOADER Device".

If your device is in [Maskrom Mode], the status line will be "Found One MASKROM Device".

### Flashing Raw Firmware

[Raw Firmware] needs to be flashed to offset 0 of eMMC storage. However, in [Rockusb Mode], all LBA writes are offset by 0x2000 sectors. Therefore, the device has to be forced into [Maskrom Mode].

To flash [Raw Firmware] to the eMMC using [AndroidTool], follow the steps below:

1. Force the device into [Maskrom Mode].
2. Run [AndroidTool].
3. Switch to the "Download Image" tab page.
4. Keep the first line of the table unchanged, using the default loader file.
5. Click the right blank cell on the second line, which will pop up a file dialog to open the [Raw Firmware] file.
6. Click the "Run" button to flash.

![](img/androidtool_flash_image.png)

### Flashing RK Firmware

To flash [RK Firmware] to the eMMC using [AndroidTool], follow the steps below:

1. Force the device into [Rockusb Mode] or [Maskrom Mode].
2. Run [AndroidTool].
3. Switch to the "Upgrade Firmware" tab page.
4. Click the "Firmware" button, which will pop up a file dialog to open the [RK Firmware] file.
5. The firmware version, loader version and chip info will be read and displayed.
6. Click the "Upgrade" button to flash.

### Flashing Partition Image

To flash [Partition Image] to the eMMC using [AndroidTool], follow the steps below:

1. Force the device into [Rockusb Mode] or [Maskrom Mode].
2. Run [AndroidTool].
3. Switch to the "Download Image" tab page.
4. Keep the first line of the table unchanged.
5. Delete all others unused rows by selecting "Delete Item" from the right-click popup menu.

    ![](img/androidtool_del.png)

6. Add partition image to flash by selection "Add Item" from the right-click popup menu.
    + Check on the checkbox on the first cell.
    + Fill in the address with the sector offset (plus `0x2000` if in [Maskrom Mode]) of partition in `parameter.txt` file.
    + Click the right blank cell to browse to the [Partition Image] file.

   ![](img/androidtool_add.png)

7. Click the "Run" button to flash.

**Note**:

- You can add multiple partitions to flash by repeating step 6.
- You can skip the partition flashing by checking off the checkbox in front of the address cell.
- In [Maskrom Mode], you must add `0x2000` to the sector offset of the partition in `parameter.txt`. See [Partition Offset](#partition-offset) for more detail.

## upgrade_tool

[upgrade_tool] is a close-sourced command line tool provided by Rockchip, which supports flashing [Raw Firmware], [RK Firmware] and [Partition Image] to the eMMC.

### Installing upgrade_tool

> [upgrade_tool Download Link](https://gitlab.com/TeeFirefly/RK3328-Nougat/blob/roc-rk3328-cc/RKTools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.24.zip)

Download [upgrade_tool], and install it to your Linux host:

    unzip Linux_Upgrade_Tool_v1.24.zip
    cd Linux_UpgradeTool_v1.24
    sudo mv upgrade_tool /usr/local/bin
    sudo chown root:root /usr/local/bin/upgrade_tool
    sudo chmod 0755 /usr/local/bin/upgrade_tool

Then add `udev` rules by instructions [here](#udev), in order to have permission for the normal user to flash Rockchip devices. If you skip this, you must prefix the following commands with `sudo` to have the right permission.

### Flashing Raw Firmware

[Raw Firmware] needs to be flashed to offset 0 of eMMC storage. However, in [Rockusb Mode], all LBA writes are offset by 0x2000 sectors. Therefore, the device has to be forced into [Maskrom Mode].

To flash [Raw Firmware] to the eMMC using [upgrade_tool], follow the steps below:

1. Force the device into [Maskrom Mode].
2. Run:

    ``` shell
    upgrade_tool db           out/u-boot/rk3328_loader_ddr786_v1.06.243.bin
    upgrade_tool wl 0x0       out/system.img
    upgrade_tool rd           # reset device to boot
    ```

Note:

- `rk3328_loader_ddr786_v1.06.243.bin` is the copied loader file after compiling `U-Boot`. It can also be downloaded from [here](https://github.com/rockchip-linux/rkbin/tree/master/rk33) (choose `rk3328_loader_xxx.bin` file).
- `system.img` is [Raw Firmware] after packing, which can also be [Raw Firmware] downloaded from official site (decompress first).

### Flashing RK Firmware

To flash [RK Firmware] to the eMMC using [upgrade_tool], follow the steps below:

1. Force the device into [Rockusb Mode] or [Maskrom Mode].
2. Run:

    ``` shell
    upgrade_tool uf update.img
    ```

### Flashing Partition Image

You can write individual [Partition Image] to the eMMC. Depending on the original content of the eMMC, the instructions can be somewhat different.

**Raw Firmware**

If the original firmware format is raw, chances are that it is using the `GPT` partition scheme, and the predefined offset and size of each partition can be found in `build/partitions.sh` in the SDK. See [Partition Offset](#partition-offset) for more detail.

To flash [Partition Image] to the eMMC using [upgrade_tool], follow the steps below:

1. Force the device into [Maskrom Mode].
2. Use [upgrade_tool] to flash the [Partition Image]:

    ``` shell
    upgrade_tool db         out/u-boot/rk3328_loader_ddr786_v1.06.243.bin
    upgrade_tool wl 0x40    out/u-boot/idbloader.img
    upgrade_tool wl 0x4000  out/u-boot/uboot.img
    upgrade_tool wl 0x6000  out/u-boot/trust.img
    upgrade_tool wl 0x8000  out/boot.img
    upgrade_tool wl 0x40000 out/linaro-rootfs.img
    upgrade_tool rd         # reset device to boot
    ```

**RK Firmware**

If the original firmware format is Rockchip, it is using the `parameter` file for partition scheme, and you can use the partition name to flash [Partition Image] directly.

To flash the [Partition Image] to the eMMC using [upgrade_tool], follow the steps below:

1. Force the device into [Rockusb Mode].
2. Use [upgrade_tool] to flash the [Partition Image]:

    ``` shell
    upgrade_tool di -b /path/to/boot.img
    upgrade_tool di -k /path/to/kernel.img
    upgrade_tool di -s /path/to/system.img
    upgrade_tool di -r /path/to/recovery.img
    upgrade_tool di -m /path/to/misc.img
    upgrade_tool di resource /path/to/resource.img
    upgrade_tool di -p parameter   # flash parameter
    upgrade_tool ul bootloader.bin # flash bootloader
    ```

Note:

- `-b` is a predefined shortcut for `boot` partition. If no shortcuts are available, use partition name instead (`resource` in above example).
- You can customize kernel parameters and partition layout according to [Parameter file format](http://www.t-firefly.com/download/Firefly-RK3399/docs/Rockchip%20Parameter%20File%20Format%20Ver1.3.pdf). Once the partition layout is changed, you must flash the `parameter` file first, before reflashing other changed partitions.

### FAQ

If errors occur due to flash storage problem, you can try to low format or erase the flash by:

    upgrade_tool lf   # low format flash
    upgrade_tool ef   # erase flash

## rkdeveloptool

[rkdeveloptool] is an open-source command line flashing tool developed by Rockchip, which is an alternative to the close-source [upgrade_tool].

[rkdeveloptool] **DOES NOT** support proprietary [RK Firmware].

### Installing rkdeveloptool

First, download, compile and install [rkdeveloptool]:

    #install libusb and libudev
    sudo apt-get install pkg-config libusb-1.0 libudev-dev libusb-1.0-0-dev dh-autoreconf
    # clone source and make
    git clone https://github.com/rockchip-linux/rkdeveloptool
    cd rkdeveloptool
    autoreconf -i
    ./configure
    make
    sudo make install

Then add `udev` rules by instructions [here](#udev), in order to have permission for the normal user to flash Rockchip devices. If you skip this, you must prefix the following commands with `sudo` to have the right permission.

### Flashing Raw Firmware

[Raw Firmware] needs to be flashed to offset 0 of eMMC storage. However, in [Rockusb Mode], all LBA writes are offset by 0x2000 sectors. Therefore, the device has to be forced into [Maskrom Mode].

To flash [Raw Firmware] to the eMMC using [rkdeveloptool], follow the steps below:

1. Force the device into [Maskrom Mode].
2. Run:

    ``` shell
    rkdeveloptool db           out/u-boot/rk3328_loader_ddr786_v1.06.243.bin
    rkdeveloptool wl 0x0       out/system.img
    rkdeveloptool rd           # reset device to boot
    ```

Note:

- `rk3328_loader_ddr786_v1.06.243.bin` is the copied loader file after compiling `U-Boot`. It can also be downloaded from [here](https://github.com/rockchip-linux/rkbin/tree/master/rk33) (choose `rk3328_loader_xxx.bin` file).
- `system.img` is [Raw Firmware] after packing, which can also be the [Raw Firmware] downloaded from official site (decompress it first).

### Flashing Partition Image

The following instructions **ONLY APPLIY** to boards which are flashed with [Raw Firmware] and use `GPT` partition scheme. The predefined offset and size of each partition can be found in `build/partitions.sh` in the SDK. See [Partition Offset](#partition-offset) for more detail.

To flash [Partition Image] to the eMMC using [rkdeveloptool], follow the steps below:

1. Force the device into [Maskrom Mode].
2. Run:

    ``` shell
    rkdeveloptool db           out/u-boot/rk3328_loader_ddr786_v1.06.243.bin
    rkdeveloptool wl 0x40      out/u-boot/idbloader.img
    rkdeveloptool wl 0x4000    out/u-boot/uboot.img
    rkdeveloptool wl 0x6000    out/u-boot/trust.img
    rkdeveloptool wl 0x8000    out/boot.img
    rkdeveloptool wl 0x40000   out/linaro-rootfs.img
    rkdeveloptool rd           # reset device to boot
    ```

## udev

Create `/etc/udev/rules.d/99-rk-rockusb.rules` with following content[1](https://github.com/rockchip-linux/rkdeveloptool/blob/master/99-rk-rockusb.rules). Replace the group `users` with your actual Linux group if neccessary:

``` shell
SUBSYSTEM!="usb", GOTO="end_rules"

# RK3036
ATTRS{idVendor}=="2207", ATTRS{idProduct}=="301a", MODE="0666", GROUP="users"
# RK3229
ATTRS{idVendor}=="2207", ATTRS{idProduct}=="320b", MODE="0666", GROUP="users"
# RK3288
ATTRS{idVendor}=="2207", ATTRS{idProduct}=="320a", MODE="0666", GROUP="users"
# RK3328
ATTRS{idVendor}=="2207", ATTRS{idProduct}=="320c", MODE="0666", GROUP="users"
# RK3368
ATTRS{idVendor}=="2207", ATTRS{idProduct}=="330a", MODE="0666", GROUP="users"
# RK3399
ATTRS{idVendor}=="2207", ATTRS{idProduct}=="330c", MODE="0666", GROUP="users"

LABEL="end_rules"
```

Reload the udev rules to take effect without reboot:

    sudo udevadm control --reload-rules
    sudo udevadm trigger

<span id="partition-offset"></span>

## Partition Offset

### GPT Partition

The offset of partition image can be obained by following command(assuming you are in the directory of Firefly Linux SDK):

    (. build/partitions.sh ; set | grep _START | \
    while read line; do start=${line%=*}; \
    printf "%-10s 0x%08x\n" ${start%_START*} ${!start}; done )

which gives result of:

    ATF        0x00006000
    BOOT       0x00008000
    LOADER1    0x00000040
    LOADER2    0x00004000
    RESERVED1  0x00001f80
    RESERVED2  0x00002000
    ROOTFS     0x00040000
    SYSTEM     0x00000000

### parameter

If [RK Firmware] is used, `parameter.txt` is used to define partition layout.

Here's a handy script to list the partition offsets in `parameter.txt`:

``` shell
#!/bin/sh

PARAMETER_FILE="$1"
[ -f "$PARAMETER_FILE" ] || { echo "Usage: $0 <parameter_file>"; exit 1; }

show_table() {
    echo "$1"
    echo "--------"
    printf "%-20s %-10s %s\n" "NAME" "OFFSET" "LENGTH"
    for PARTITION in `cat ${PARAMETER_FILE} | grep '^CMDLINE' | sed 's/ //g' | sed 's/.*:\(0x.*[^)])\).*/\1/' | sed 's/,/ /g'`; do
        NAME=`echo ${PARTITION} | sed 's/\(.*\)(\(.*\))/\2/'`
        START=`echo ${PARTITION} | sed 's/.*@\(.*\)(.*)/\1/'`
        LENGTH=`echo ${PARTITION} | sed 's/\(.*\)@.*/\1/'`
        START=$((START + $2))
        printf "%-20s 0x%08x %s\n" $NAME $START $LENGTH
    done
}

show_table "Rockusb Mode" 0
echo
show_table "Maskrom Mode" 0x2000
```

Save it as a script in `/usr/local/bin/show_rk_parameter.sh` and give the script executing permission.

Here's an example of showing partition offsets defined in `RK3328 Android SDK`:

```text
$ show_rk_parameter.sh device/rockchip/rk3328/parameter.txt
Rockusb Mode
--------
NAME                 OFFSET     LENGTH
uboot                0x00002000 0x00002000
trust                0x00004000 0x00004000
misc                 0x00008000 0x00002000
baseparamer          0x0000a000 0x00000800
resource             0x0000a800 0x00007800
kernel               0x00012000 0x00010000
boot                 0x00022000 0x00010000
recovery             0x00032000 0x00010000
backup               0x00042000 0x00020000
cache                0x00062000 0x00040000
metadata             0x000a2000 0x00008000
kpanic               0x000aa000 0x00002000
system               0x000ac000 0x00300000
userdata             0x003ac000 -

Maskrom Mode
--------
NAME                 OFFSET     LENGTH
uboot                0x00004000 0x00002000
trust                0x00006000 0x00004000
misc                 0x0000a000 0x00002000
baseparamer          0x0000c000 0x00000800
resource             0x0000c800 0x00007800
kernel               0x00014000 0x00010000
boot                 0x00024000 0x00010000
recovery             0x00034000 0x00010000
backup               0x00044000 0x00020000
cache                0x00064000 0x00040000
metadata             0x000a4000 0x00008000
kpanic               0x000ac000 0x00002000
system               0x000ae000 0x00300000
userdata             0x003ae000 -
```

[Rockusb Mode]: flash_emmc.html#rockusb-mode
[Maskrom Mode]: flash_emmc.html#maskrom-mode
[Raw Firmware]: started.html#raw_firmware_format
[RK Firmware]: started.html#rockchip_firmware_format
[Partition Image]: started.html#partition_image
[AndroidTool]: flash_emmc.html#androidtool
[upgrade_tool]: flash_emmc.html#upgrade-tool
[rkdeveloptool]: flash_emmc.html#rkdeveloptool
[install Rockusb Driver]: flash_emmc.html#install-rockusb-driver
