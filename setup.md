# Initial setup

1. Download [Raspbian image](https://www.raspberrypi.org/downloads/raspbian/)

2. Flash with [Etcher](https://etcher.io/) or Raspberry Pi Imager

3. re-insert SD card and create empty `ssh` file on the boot partition

4. Boot

5. From the host: `ssh-copy-id pi@ip.ip.ip.ip`

   Use `raspberry` password.
   
   Then `ssh pi@ip.ip.ip.ip`

6. Configure with `sudo raspi-config`

   Set locale to `en_US.UTF-8`

7. Shutdown with `sudo halt`


# Increase swap

```bash
sudo dphys-swapfile swapoff

# Set CONF_SWAPSIZE=1024
sudo vim /etc/dphys-swapfile

sudo dphys-swapfile setup
sudo dphys-swapfile swapon
```


# Update packages

Update OS packages:

	sudo apt update
	sudo apt full-upgrade -y
	
Remove partial packages, clean the cache, remove unused dependencies:

	sudo apt-get autoclean
	sudo apt-get clean
	sudo apt-get autoremove
	
Update kernel:

	sudo rpi-update


# Clone SD card

```bash
# List devices and partitions:
lsblk
df -T
```

Lets say target disk is `/dev/sdb`

Check capacity with `sudo fdisk -l /dev/sdb`

```bash
# Save disk image
# Assuming partitionas are at /dev/sdb*
sudo umount /dev/sdb*
sudo dd if=/dev/sdb of=backup.img status=progress

# Restore disk image
sudo umount /dev/sdb*
sudo dd if=backup.img of=/dev/sdb status=progress
```



Note the common issue: target SD card have lower capacity:

```log
63218160128 bytes (63 GB, 59 GiB) copied, 8047 s, 7.9 MB/s 
dd: writing to '/dev/sdb': No space left on device
123473921+0 records in
123473920+0 records out
63218647040 bytes (63 GB, 59 GiB) copied, 8062.15 s, 7.8 MB/s
```

Possible fix (assuming 4 partitions, last of which were corrupted due to superblock record of the initial card had different block count):

Note: It will delete and recreate the last partititon (data will be lost - make the backup beforehand)!

```bash
sudo fsck /dev/sdb4

sudo fdisk /dev/sdb

# list partitions
> p

# delete the last partition
> d

# create a new partition (primary)
> n

# write the changes 
> w

sudo mkfs -t ext4 -L UNTITLED /dev/sdb4

# Check the capacity is correct:
sudo fdisk -l /dev/sdb
```

