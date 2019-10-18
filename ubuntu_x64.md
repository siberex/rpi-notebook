# Ubuntu ARM64 setup for Raspberry Pi 3

[Official wiki](https://wiki.ubuntu.com/ARM/RaspberryPi)

1. Prerequisites:

    - [balenaEtcher](https://www.balena.io/etcher/) or `dd` + `xzcat`.
    
    - [Disk image](http://cdimage.ubuntu.com/ubuntu/releases/bionic/release/) from releases page.
    
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


## Backup SD card as disk image

```bash
diskutil list
sudo diskutil unmountDisk /dev/diskNUMBER
sudo dd bs=4m if=/dev/diskNUMBER | xz > ubuntu.`date +%Y-%m-%d`.img.xz
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

[Enable swap](https://tecadmin.net/enable-swap-on-ubuntu/):

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


Disable root login and password-based SSH login:

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

## Update WiFi driver

Check `dmesg` output:
```
[   17.874298] brcmfmac: brcmf_c_preinit_dcmds: Firmware version = wl0: Aug 29 2016 20:48:16 version 7.45.41.26 (r640327) FWID 01-4527cfab
```

For Pi Model 3B follow this:

```bash
cd /tmp
curl -L -O https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43430-sdio.bin
curl -L -O https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43430-sdio.txt
```

Use `dpkg-divert` to stop driver files being overwritten on package updates:

```bash
# 
sudo dpkg-divert --add --rename --divert /lib/firmware/brcm/brcmfmac43430-sdio.bin.orig /lib/firmware/brcm/brcmfmac43430-sdio.bin
sudo dpkg-divert --add --rename --divert /lib/firmware/brcm/brcmfmac43430-sdio.txt.orig /lib/firmware/brcm/brcmfmac43430-sdio.txt
```

Copy new drivers:

```bash
sudo cp *sdio* /lib/firmware/brcm/
sudo reboot
```

Check `dmesg` output after reboot:
```
[   18.109556] brcmfmac: brcmf_c_preinit_dcmds: Firmware version = wl0: Oct 23 2017 03:55:53 version 7.45.98.38 (r674442 CY) FWID 01-e58d219f
```


## Additional info

System configuration and (`arm_64bit` should be set to non-zero):
```bash
cat /boot/firmware/config.txt
```

Kernel command line options:
```bash
cat /boot/firmware/cmdline.txt
```

