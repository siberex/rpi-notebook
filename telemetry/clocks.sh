#!/bin/bash

# watch -n 1 -- ./status.sh

printf '%(%Y-%m-%d %H:%M:%S)T\n' -1

# See also: https://www.elinux.org/RPI_vcgencmd_usage

# Current CPU frequency:
# 1200000
# cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq

# Measure clocks
for src in arm core h264 isp v3d uart pwm emmc pixel vec hdmi dpi ; do
    echo -e "$src:\t$(vcgencmd measure_clock $src)";
done

# Measure voltages
for id in core sdram_c sdram_i sdram_p ; do
    echo -e "$id:\t$(vcgencmd measure_volts $id)" ;
done
