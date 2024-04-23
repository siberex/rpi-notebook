# Miscellaneous tips and tricks


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
