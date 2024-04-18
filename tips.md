# Miscellaneous tips and tricks


### Trigger LED

Note: [depends on kernel version](https://github.com/raspberrypi/linux/pull/5805)

```bash
echo heartbeat > /sys/class/leds/ACT/trigger
```


### Fan PWM control

Connect PWM pin to GPIO 14, for example:

```bash
sudo vim /boot/config.txt
```

```conf
dtoverlay=gpio-fan,gpiopin=14,temp=55000
```
