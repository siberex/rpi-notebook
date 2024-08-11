# Miscellaneous tips and tricks

Temperature:

```bash
cat /sys/class/thermal/thermal_zone0/temp
```

Oscillator clock frequjency:

```bash
cat /sys/kernel/debug/clk/osc/clk_rate
```

Device tree details:

```bash
dtc -I fs /proc/device-tree
```

Get boot config setting current value

```bash
vcgencmd get_config arm_peri_high
vcgencmd get_config gpu_mem
vcgencmd get_config gpu_freq
vcgencmd get_config isp_freq
```


### Storage performance benchmark

```bash
# sudo apt install hdparm
sudo hdparm -tT --direct /dev/mmcblk0p3

    /dev/mmcblk0p3:
    Timing O_DIRECT cached reads:    46 MB in  2.08 seconds =  22.09 MB/sec
    Timing O_DIRECT disk reads:  66 MB in  3.03 seconds =  21.76 MB/sec

sudo dd if=/dev/zero of=test bs=4k count=80k conv=fsync
    81920+0 records in
    81920+0 records out
    335544320 bytes (336 MB, 320 MiB) copied, 26.8066 s, 12.5 MB/s

# sudo apt install iozone3 fio
sudo fio --minimal --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=80M --readwrite=randwrite
sudo fio --minimal --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=80M --readwrite=randread
sudo iozone -a -e -I -i 0 -i 1 -i 2 -s 80M -r 4k

mkdir tmp
iozone -t1 -i0 -i2 -r1k -s1g ./tmp
```


### Voltages

```bash
vcgencmd pmic_read_adc
watch -c -b -n 1 -- "vcgencmd pmic_read_adc | grep EXT5V_V"
```


### [Bootlopader config](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#raspberry-pi-bootloader-configuration)

rPi4 and rPi5:

```conf
# sudo rpi-eeprom-config --edit
[all]
BOOT_UART=1

# https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#decrease-raspberry-pi-5-wattage-when-turned-off
WAKE_ON_GPIO=0
POWER_OFF_ON_HALT=1
# Disable HDMI boot diagnostics display
DISABLE_HDMI=1

# When powered from PoE, Pi 5 only:
PSU_MAX_CURRENT=5000

BOOT_ORDER=0xf164
```


### Bootloader update

TODO


## rPi5 additional config options

[RTC battery charging](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#enable-battery-charging)

```conf
usb_max_current_enable=1

# vcgencmd pmic_read_adc BATT_V
# timedatectl
# ls -la /sys/devices/platform/soc/soc:rpi_rtc/rtc/rtc0
dtparam=rtc_bbat_vchg=3000000

#dtoverlay=disable-bt
#dtparam=audio=off

# Enable Type C port host mode
#dtoverlay=dwc2,dr_mode=host

# Command queueing for A2 microSD cards
# https://forums.raspberrypi.com/viewtopic.php?t=367459
dtparam=sd_cqe

# FAN PWM
# https://gist.github.com/s-geissler/89d2dbe8ee75e67aaadf5c870cf9291e
dtparam=fan_temp0=47000
dtparam=fan_temp0_hyst=6000
dtparam=fan_temp0_speed=50
dtparam=fan_temp3_speed=255
```


### Trigger LED

Note: [depends on kernel version](https://github.com/raspberrypi/linux/pull/5805)

```bash
echo heartbeat > /sys/class/leds/ACT/trigger
```


### Temperature fan control

**Warning**: fan must be connected via N-MOSFET like 2N7002 [and flyback diode with gate resistor](https://scarff.id.au/blog/2021/circuit-for-temperature-controlled-dual-fan-raspberry-pi-case/).

For a brushless DC fan, flyback diode is not necessary.

[overlay source](https://github.com/raspberrypi/linux/blob/rpi-6.6.y/arch/arm/boot/dts/overlays/gpio-fan-overlay.dts)

```bash
sudo vim /boot/config.txt
```

```conf
dtoverlay=gpio-fan,gpiopin=14,temp=55000
```

See also [hwmon source](https://github.com/torvalds/linux/blob/71b1543c83d65af8215d7558d70fc2ecbee77dcf/drivers/hwmon/raspberrypi-hwmon.c)


### Proper PWM fan control

[Daemon from PiKVM project](https://github.com/pikvm/kvmd-fan/)

[Configuration](https://github.com/pikvm/kvmd-fan/blob/master/src/main.c#L81) example:

```bash
cat /etc/conf.d/kvmd-fan
KVMD_FAN_ARGS="--verbose --speed-idle 5 --speed-low 5 --temp-low 30 --speed-high 50 --temp-high 55 --temp-hyst 3 --hall-pin 25 --hall-bias 2"
```
