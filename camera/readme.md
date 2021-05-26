
# Motion + MotionEye

Option 1: [Get MotionEyeOS image](https://github.com/ccrisan/motioneyeos/wiki/Installation)

Option 2: Set up [motion and motionEye manually](https://github.com/ccrisan/motioneye/wiki/%28Install-On-Ubuntu-%2820.04-or-Newer%29)

...TODO


# ZoneMinder

Option 1: [Get Raspbian Lite image](https://zmrepo.zoneminder.com/)

Option 2: [Install on Ubuntu aarch64](https://zoneminder.readthedocs.io/en/latest/installationguide/ubuntu.html#easy-way-ubuntu-18-04-bionic)

```bash

sudo add-apt-repository ppa:iconnor/zoneminder-1.34
sudo apt update

sudo apt install -y tasksel
sudo tasksel install lamp-server

sudo apt install zoneminder

sudo chmod 740 /etc/zm/zm.conf
sudo chown root:www-data /etc/zm/zm.conf
sudo chown -R www-data:www-data /usr/share/zoneminder/

a2enmod cgi expires headers rewrite
a2enconf zoneminder

sudo systemctl enable zoneminder
sudo systemctl start zoneminder

sudo systemctl reload apache2
```

Browse to `http://hostname_or_ip/zm`
