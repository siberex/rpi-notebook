#!/bin/bash

# watch -n 1 -- ./status.sh

printf '%(%Y-%m-%d %H:%M:%S)T\n' -1

# See also: https://www.elinux.org/RPI_vcgencmd_usage

# Current CPU frequency
# 1200000
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq

# Measure clock:
# vcgencmd measure_clock core
# frequency(1)=400000000
# vcgencmd measure_clock pwm
# frequency(25)=600000
vcgencmd measure_clock arm
# frequency(48)=1200000000
#clock can be one of arm, core, h264, isp, v3d, uart, pwm, emmc, pixel, vec, hdmi, dpi.


# CPU voltage
# volt=1.3375V
vcgencmd measure_volts core


# Chip temperature
# Note: temperature sensor for the CPU and GPU is the same
# cat /sys/class/thermal/thermal_zone0/temp
# 39166
cpu=$(</sys/class/thermal/thermal_zone0/temp)
echo "vcgencmd => $(vcgencmd measure_temp)"
echo "sys => $((cpu/100))"

# vcgencmd measure_volts 
# vcgencmd measure_volts sdram_p
# volt=1.2250V
#
# for id in core sdram_c sdram_i sdram_p ; do
#     echo -e "$id:t$(vcgencmd measure_volts $id)" ;
# done