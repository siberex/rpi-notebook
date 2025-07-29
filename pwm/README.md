

https://github.com/raspberrypi/linux/blob/rpi-6.1.y/drivers/pwm/pwm-bcm2835.c#L61





Note: `bcm_host_get_peripheral_address()` is outdated and [not recommended](https://github.com/raspberrypi/documentation/issues/3350)

Quick setup to mmap peripherial registers: https://github.com/librerpi/rpi-open-firmware/blob/master/utils/map_peripherals.cpp#L16-L36


## Prerequisites

Debian

```bash
sudo apt-get install libraspberrypi-dev raspberrypi-kernel-headers
```
