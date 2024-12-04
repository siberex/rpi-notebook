#!/usr/bin/env bash

printf '%(%Y-%m-%d %H:%M:%S)T\n' -1

# Note rPi CPU and GPU are on the same chip, and GPU don't hanve any separate temperature sensor
# vcgencmd and sysfs provide the same data

temp_vcgencmd=$(vcgencmd measure_temp | grep  -Eo '[[:digit:]]+.?[[:digit:]]*')
echo "t_vcgencmd  => $temp_vcgencmd °C"

if [ -f "/sys/class/thermal/thermal_zone0/temp" ]; then
    cpu_temp_sysfs=$(cat /sys/class/thermal/thermal_zone0/temp)
    temp_sysfs=$(echo "scale=1; $cpu_temp_sysfs / 1000" | bc)
    echo "t_sysfs     => $temp_sysfs °C"
fi

# PMIC (Pi 4 and Pi 5)
temp_pmic=$(vcgencmd measure_temp pmic | grep  -Eo '[[:digit:]]+.?[[:digit:]]*')
echo "PMIC        => $temp_pmic °C"

# RP1 (Pi 5 only)
temp_rp1=$(python -c "import psutil; print(psutil.sensors_temperatures()['rp1_adc'][0].current)")
echo "RP1         => $temp_rp1 °C"

# See also: s-tui
# https://github.com/amanusk/s-tui
# https://github.com/giampaolo/psutil

# Coral Edge TPU
for device_path in /sys/class/apex/apex_*; do
    if [ -f "$device_path/temp" ]; then
        device_name=$(basename "$device_path")
        temp_milli_c=$(cat "$device_path/temp")
        temp_c=$(echo "scale=1; $temp_milli_c / 1000" | bc)
        echo "$device_name      => $temp_c °C"
    fi
done


# Usage:
# watch -c -b -n 1 -- './temperature.sh'
# watch -c -b -n 1 -- vcgencmd measure_temp
