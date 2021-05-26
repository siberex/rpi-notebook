
# Motion + MotionEye

Option 1: [Get MotionEyeOS image](https://github.com/ccrisan/motioneyeos/wiki/Installation)

Option 2: Set up [motion and motionEye manually](https://github.com/ccrisan/motioneye/wiki/%28Install-On-Ubuntu-%2820.04-or-Newer%29)

```bash
sudo apt install -y ssh curl motion ffmpeg v4l-utils

cd /tmp
sudo apt install -y python2
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
sudo python2 get-pip.py

sudo apt install -y libffi-dev libzbar-dev libzbar0
sudo apt install -y python2-dev libssl-dev libcurl4-openssl-dev libjpeg-dev
sudo apt install -y python-pil

sudo pip2 install motioneye
sudo mkdir -p /etc/motioneye
sudo cp /usr/local/share/motioneye/extra/motioneye.conf.sample /etc/motioneye/motioneye.conf

sudo mkdir -p /var/lib/motioneye

sudo cp /usr/local/share/motioneye/extra/motioneye.systemd-unit-local /etc/systemd/system/motioneye.service
sudo systemctl daemon-reload
sudo systemctl enable motioneye
sudo systemctl start motioneye
```

Browse to `http://hostname_or_ip:8765/` (Username `admin` with blank password)

Add camera streams, for example `rtsp://192.168.1.200:554/cam/realmonitor?channel=1&subtype=0&unicast=true&proto=Onvif` (for Dahua)


# ZoneMinder

Option 1: [Get Raspbian Lite image](https://zmrepo.zoneminder.com/)

Tip: [Increase GPU mem](https://wiki.zoneminder.com/Single_Board_Computers#GPU_Memory) to improve performance

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
