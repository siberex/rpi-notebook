# Initial setup

1. Download [Raspbian image](https://www.raspberrypi.org/downloads/raspbian/)

2. Flush with [Etcher](https://etcher.io/)

3. Boot and login using `pi` username and `raspberry` password.

4. Configure with `sudo raspi-config`

5. Shutdown with `sudo halt`


# Update packages

Update OS packages:

	sudo apt-get update
	sudo apt-get upgrade
	sudo apt-get dist-upgrade
	
Remove partial packages, clean the cache, remove unused dependencies:

	sudo apt-get autoclean
	sudo apt-get clean
	sudo apt-get autoremove
	
Update kernel:

	sudo rpi-update


