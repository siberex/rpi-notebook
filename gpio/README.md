## Generic tips


Sysfs deprecated

https://lloydrochester.com/post/hardware/libgpiod-intro-rpi/

https://forums.raspberrypi.com/viewtopic.php?t=343514


```bash
sudo apt install gpiod
gpioinfo
```


Status all pins:

```bash
sudo raspi-gpio get
```


## [Mailboxes](https://github.com/raspberrypi/firmware/wiki/Mailboxes) interface

[CLang example](https://github.com/6by9/rpi3-gpiovirtbuf/blob/master/rpi3-gpiovirtbuf.c)

```bash
git clone https://github.com/6by9/rpi3-gpiovirtbuf.git
cd rpi3-gpiovirtbuf
gcc -o gpiovirtbuf rpi3-gpiovirtbuf.c
./gpiovirtbuf g 23
```


## [WiringPi](https://github.com/WiringPi/WiringPi)

```bash
git clone https://github.com/WiringPi/WiringPi.git
cd WiringPi
./build debian

mv debian-template/wiringpi_3.2_arm64.deb .
sudo apt install ./wiringpi_3.2_arm64.deb

gpio readall
```


### Examples

See also:

- [man gpio](https://github.com/WiringPi/WiringPi/blob/master/gpio/gpio.1)

- [CLang examples](https://github.com/WiringPi/WiringPi/blob/master/examples/pwm.c)

```bash
# Set pin 32 (aka GPIO 12, aka wPi 26) to PWM mode
gpio mode 26 pwm
# This is the same as setting it to Alt0 (for GPIO 18 it will be Alt5)
# Set ALT0 mode on GPIO 12 assigning it PWM0
gpio mode 26 alt0
# Set ALT5 mode on GPIO 18 assigning it PWM0
gpio mode 1 alt5

# Set the PWM mode to mark-space (default is pwm-bal)
gpio pwm-ms

# Set pin 32 to PWM value 512 - half duty cycle
# PWM values: 0..1023
gpio pwm 26 512

# Set pin 31 (GPIO 6 / wPi 22) to Input pull-up mode
gpio mode 22 up
```

