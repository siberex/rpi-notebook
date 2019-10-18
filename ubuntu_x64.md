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

## First boot

user: `ubuntu` \
pass: `ubuntu` 


## Backup SD card as disk image

```bash
diskutil list
sudo diskutil unmountDisk /dev/diskNUMBER
sudo dd bs=4m if=/dev/diskNUMBER | xz > ubuntu.`date +%Y-%m-%d`.img.xz
```
