# Ubuntu ARM64 setup for Raspberry Pi 3

## OS Image

Recommended way:

Use [Raspberry Pi Imager](https://www.raspberrypi.org/software/)

Select: Other general purpose OS → Ubuntu → Ubuntu Server 20.04 LTS 64-bit

<details><summary>Manual way (not recommended)</summary>
<p>

[Official wiki](https://wiki.ubuntu.com/ARM/RaspberryPi)

1. Prerequisites:

    - [balenaEtcher](https://www.balena.io/etcher/) or `dd` + `xzcat`.
    
    - [Disk image](http://cdimage.ubuntu.com/ubuntu/releases/20.04/release/) from releases page.
    
        Preinstalled server image → Raspberry Pi 3 (64-bit ARM) preinstalled server image.

2. Flash SD card:

    Without Etcher it can be done like this:
    
    ```bash
    cd /tmp
    curl -L -O http://cdimage.ubuntu.com/ubuntu/releases/bionic/release/ubuntu-18.04.3-preinstalled-server-arm64+raspi3.img.xz
    diskutil list
    sudo diskutil unmountDisk /dev/diskNUMBER
    xzcat ubuntu-18.04.3-preinstalled-server-arm64+raspi3.img.xz | sudo dd bs=4m of=/dev/diskNUMBER
    ```

</p></details>

## Backup SD card as disk image

```bash
diskutil list
sudo diskutil unmountDisk /dev/diskNUMBER
sudo dd bs=4m if=/dev/diskNUMBER | xz > ubuntu.`date +%Y-%m-%d`.img.xz
```

Restore with:

```bash
diskutil list
sudo diskutil unmountDisk /dev/diskNUMBER
xzcat ubuntu.2019-10-20.img.xz | sudo dd bs=4m of=/dev/diskNUMBER
```

## First boot

user: `ubuntu` \
pass: `ubuntu` 

Update packages:

```bash
sudo apt update -y
sudo apt upgrade -y
sudo apt dist-upgrade -y
```

## [Enable swap](https://tecadmin.net/enable-swap-on-ubuntu/):

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
echo 'vm.swappiness=60' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

Check swap:

```bash
free -h
sudo swapon --show
cat /proc/sys/vm/swappiness
```


## Disable root login and password-based SSH login:

1. Add ssh key(s) to `~/.ssh/authorized_keys`

2. Disable unsecure sshd options:

    ```bash
    sudo vim /etc/ssh/sshd_config
    # PermitRootLogin no
    # PasswordAuthentication no
    # ChallengeResponseAuthentication no
    # UsePAM no
    ```
   
3. Reload sshd:

    ```bash
    sudo systemctl reload ssh
    ```

## <s>Update WiFi driver</s>

Not needed with the current Ubuntu.

Check `dmesg` output:
```
[   17.874298] brcmfmac: brcmf_c_preinit_dcmds: Firmware version = wl0: Aug 29 2016 20:48:16 version 7.45.41.26 (r640327) FWID 01-4527cfab
```

<details><summary>Instructions to update Broadcom/Cypress driver manually</summary>
<p>

Use this to obtain latest [Cypress WiFi firmware](https://github.com/RPi-Distro/firmware-nonfree/commit/4ee44af381d55bc2221cf80c1433842a48ed09e1) for Pi Model 3B:

```shell script
cd /tmp
curl -L -O https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43430-sdio.bin
curl -L -O https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43430-sdio.clm_blob
curl -L -O https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43430-sdio.txt

curl -L -O https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43455-sdio.bin
curl -L -O https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43455-sdio.clm_blob
curl -L -O https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43455-sdio.txt
```

*Cypress are the new owners of what used to be Broadcom’s wireless business*

Use `dpkg-divert` to stop firmware files being overwritten on package updates:

```shell script
sudo dpkg-divert --add --rename --divert /lib/firmware/brcm/brcmfmac43430-sdio.bin.orig /lib/firmware/brcm/brcmfmac43430-sdio.bin
sudo dpkg-divert --add --rename --divert /lib/firmware/brcm/brcmfmac43430-sdio.clm_blob.orig /lib/firmware/brcm/brcmfmac43430-sdio.clm_blob
sudo dpkg-divert --add --rename --divert /lib/firmware/brcm/brcmfmac43430-sdio.txt.orig /lib/firmware/brcm/brcmfmac43430-sdio.txt

sudo dpkg-divert --add --rename --divert /lib/firmware/brcm/brcmfmac43455-sdio.bin.orig /lib/firmware/brcm/brcmfmac43455-sdio.bin
sudo dpkg-divert --add --rename --divert /lib/firmware/brcm/brcmfmac43455-sdio.clm_blob.orig /lib/firmware/brcm/brcmfmac43455-sdio.clm_blob
sudo dpkg-divert --add --rename --divert /lib/firmware/brcm/brcmfmac43455-sdio.txt.orig /lib/firmware/brcm/brcmfmac43455-sdio.txt
```

Copy new drivers:

```shell script
sudo cp *sdio* /lib/firmware/brcm/
sudo reboot
```

Check `dmesg` output after reboot:
```
[   18.359555] brcmfmac: brcmf_c_preinit_dcmds: Firmware version = wl0: May  2 2019 02:39:18 version 7.45.98.83 (r714225 CY) FWID 01-e539531f
```

</p></details>

## Set up WiFi connection

```bash
cat /etc/netplan/60-wifi.yaml
```

```yaml
network:
    version: 2
    wifis:
        wlan0:
            optional: true
            dhcp4: true
            nameservers:
                addresses: [ 1.1.1.1, 1.0.0.1 ]
            access-points:
                "my-wifi-ssid":
                    password: "password"
                "another-wifi-ssid":
                    password: "another-password"
```

Side note: add `optional: true` to the default interface too (`/etc/netplan/50-cloud-init.yaml`),
 to [reduce boot time](https://askubuntu.com/questions/972215/a-start-job-is-running-for-wait-for-network-to-be-configured-ubuntu-server-17-1).


## Additional info

System configuration and (`arm_64bit` should be set to non-zero):

```bash
cat /boot/firmware/config.txt
```

Kernel command line options:

```bash
cat /boot/firmware/cmdline.txt
```


## Userland utils (vcgencmd) from Raspbian

[rPi userland utils](https://github.com/raspberrypi/userland) **ARE USELESS**!

DO NOT install them with `sudo apt install -y libraspberrypi-bin`

`vcgencmd measure_temp` WILL NOT work on Ubuntu aarch64 (you wil get `VCHI initialization failed`).

If you want to get CPU info, use this (and `lscpu`):

```bash
printf "CPU Temp: %.2f°C\n" `echo "$(</sys/class/thermal/thermal_zone0/temp)/1000" | bc -l`
echo "CPU Freq:" $(($(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)/1000))MHz
```


## Mount exFAT file systems

1. Add universe repos (open-source community-maintained packages) and install exfat-fuse:

    ```bash
    # sudo add-apt-repository universe
    # sudo apt update
    sudo apt install -y exfat-fuse exfat-utils
    ```

2. Check drive is connected:

    ```bash
    lsusb -t
    ```

    Check `dmesg` if not.

3. Get list of connected drives and partitions:

    ```bash
    sudo fdisk -l
    ls -l /dev/disk/by-id/usb*
    lsblk
    ```
   
4. Mount desired partition:

    ```bash
    sudo mkdir -p /media/usb
    sudo mount -t exfat /dev/sda2 /media/usb
    ```

5. Optionally, add mount point to `/etc/fstab` to mount on boot.

    Get partition label:
    
    ```bash
    sudo blkid
    ```
   
    Update `/etc/fstab`:
    
    ```bash
    sudo vim /etc/fstab
    LABEL=dumpster /media/dumpster exfat-fuse defaults 0 0
    ```

    Check is it’s actually mounting and re-mount:
    ```bash
    sudo umount /dev/sda2
    sudo mount -av
    sudo mount -a
    ```
