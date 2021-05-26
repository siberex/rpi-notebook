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


