# Ubuntu ARM64 setup for Raspberry Pi 3

[Official wiki](https://wiki.ubuntu.com/ARM/RaspberryPi)

1. Prerequisites:

    - [balenaEtcher](https://www.balena.io/etcher/) or `dd` + `xzcat`.
    
    - [Disk image](http://cdimage.ubuntu.com/ubuntu/releases/bionic/release/) from releases page.
    
        Preinstalled server image → Raspberry Pi 3 (64-bit ARM) preinstalled server image.

2. Flash SD card:

    Without Etcher it can be done like this:
    
    ```shell script
    cd /tmp
    curl -L -O http://cdimage.ubuntu.com/ubuntu/releases/bionic/release/ubuntu-18.04.3-preinstalled-server-arm64+raspi3.img.xz
    diskutil list
    sudo diskutil unmountDisk /dev/diskNUMBER
    xzcat ubuntu-18.04.3-preinstalled-server-arm64+raspi3.img.xz | sudo dd bs=4m of=/dev/diskNUMBER
    ```


## Backup SD card as disk image

```shell script
diskutil list
sudo diskutil unmountDisk /dev/diskNUMBER
sudo dd bs=4m if=/dev/diskNUMBER | xz > ubuntu.`date +%Y-%m-%d`.img.xz
```

Restore with:

```shell script
diskutil list
sudo diskutil unmountDisk /dev/diskNUMBER
xzcat ubuntu.2019-10-20.img.xz | sudo dd bs=4m of=/dev/diskNUMBER
```

## First boot

user: `ubuntu` \
pass: `ubuntu` 

Update packages:

```shell script
sudo apt update -y
sudo apt upgrade -y
sudo apt dist-upgrade -y
```

[Enable swap](https://tecadmin.net/enable-swap-on-ubuntu/):

```shell script
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
echo 'vm.swappiness=60' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

Check swap:

```shell script
free -h
sudo swapon --show
cat /proc/sys/vm/swappiness
```


Disable root login and password-based SSH login:

1. Add ssh key(s) to `~/.ssh/authorized_keys`

2. Disable unsecure sshd options:

    ```shell script
    sudo vim /etc/ssh/sshd_config
    # PermitRootLogin no
    # PasswordAuthentication no
    # ChallengeResponseAuthentication no
    # UsePAM no
    ```
   
3. Reload sshd:

    ```shell script
    sudo systemctl reload ssh
    ```

## Update WiFi driver

Check `dmesg` output:
```
[   17.874298] brcmfmac: brcmf_c_preinit_dcmds: Firmware version = wl0: Aug 29 2016 20:48:16 version 7.45.41.26 (r640327) FWID 01-4527cfab
```

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


## Set up WiFi connection

```shell script
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
```shell script
cat /boot/firmware/config.txt
```

Kernel command line options:
```shell script
cat /boot/firmware/cmdline.txt
```


## Mount exFAT file systems

1. Add universe repos (open-source community-maintained packages) and install exfat-fuse:

    ```shell script
    sudo add-apt-repository universe
    sudo apt update
    sudo apt install -y exfat-fuse exfat-utils
    ```

2. Check drive is connected:

    ```shell script
    lsusb -t
    ```

    Check `dmesg` if not.

3. Get list of connected drives and partitions:

    ```shell script
    sudo fdisk -l
    ls -l /dev/disk/by-id/usb*
    lsblk
    ```
   
4. Mount desired partition:

    ```shell script
    sudo mkdir -p /media/usb
    sudo mount /dev/sda2 /media/usb
    ```

5. Optionally, add mount point to `/etc/fstab` to mount on boot.

    Get partition label:
    
    ```shell script
    sudo blkid
    ```
   
    Update `/etc/fstab`:
    
    ```shell script
    sudo vim /etc/fstab
    LABEL=dumpster /media/usb auto defaults 0 0
    ```

