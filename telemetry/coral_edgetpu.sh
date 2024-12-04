#!/usr/bin/env bash

printf '%(%Y-%m-%d %H:%M:%S)T\n' -1

# Dynamically find all apex devices and read their temperatures
for device_path in /sys/class/apex/apex_*; do
    if [ -f "$device_path/temp" ]; then
        device_name=$(basename "$device_path")
        temp_milli_c=$(cat "$device_path/temp")
        temp_c=$(echo "scale=1; $temp_milli_c / 1000" | bc)
        echo "$device_name: $temp_c °C"
    else
        echo "$device_name: Temperature readout not available"
    fi
done
