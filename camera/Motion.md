
# Motion + MotionEye

Option 1: [Get MotionEyeOS image](https://github.com/ccrisan/motioneyeos/wiki/Installation)

Option 2: Set up motion and motionEye manually

...TODO


# ZoneMinder

Option 1: [Get Raspbian Lite image](https://zmrepo.zoneminder.com/)

Option 2: [Install on Ubuntu aarch64](https://zoneminder.readthedocs.io/en/latest/installationguide/ubuntu.html#easy-way-ubuntu-18-04-bionic)

```bash

sudo add-apt-repository ppa:iconnor/zoneminder-1.34
sudo apt update

sudo apt install -y tasksel
sudo tasksel install lamp-server

sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
# In the [mysqld] section add the following
# sql_mode = NO_ENGINE_SUBSTITUTION

sudo systemctl restart mysql
sudo apt install zoneminder

# ...
```
