#!/usr/bin/env bash

printf '%(%Y-%m-%d %H:%M:%S)T\n' -1

# Note rPi CPU and GPU are on the same chip, and GPU don't hanve any separate temperature sensor
# vcgencmd and sysfs provide the same data

cpu_temp_sysfs=$(</sys/class/thermal/thermal_zone0/temp)
echo "vcgencmd => $(vcgencmd measure_temp | grep  -o -E '[[:digit:]].*')"
echo "sysfs => $((cpu_temp_sysfs/1000))'C"

# RP1 (Pi 5 only)
# python -c "import psutil; print(psutil.sensors_temperatures()['rp1_adc'][0].current)"

# PMIC (Pi 4 and Pi 5)
# vcgencmd measure_temp pmic

# watch -c -b -n 1 -- './temperature.sh'
# watch -c -b -n 1 -- vcgencmd measure_temp

# sudo apt install s-tui stress-ng
#
# s-tui
# stress-ng --cpu 0 --cpu-method fft

# glxgears -fullscreen

# sudo apt-get install -y hdparm
# sudo fdisk -l
# sudo hdparm -t /dev/mmcblk0
# sudo hdparm -T /dev/mmcblk0

# https://github.com/geerlingguy/raspberry-pi-dramble/issues/7

# wget http://www.iozone.org/src/current/iozone3_506.tar
# cat iozone3_506.tar | tar -x
# cd iozone3_506/src/current
# make linux-arm
# ./iozone -e -I -a -s 100M -r 4k -r 512k -r 16M -i 0 -i 1 -i 2
