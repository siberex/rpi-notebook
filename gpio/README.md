# rPi GPIO

List of libraries, tools and ways to access Raspberry Pi [GPIO](https://pinout.xyz/).

## Generic info

[Sysfs is deprecated](https://forums.raspberrypi.com/viewtopic.php?t=343514) since around late 2022.

See also libgpiod section.

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


## [bcm2835](https://airspayce.com/mikem/bcm2835/)

[PWM API](https://airspayce.com/mikem/bcm2835/group__pwm.html)

[PWM example](https://airspayce.com/mikem/bcm2835/pwm_8c-example.html)


## [gpiod / libgpiod](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/about/)

[https://lloydrochester.com/post/hardware/libgpiod-intro-rpi/](libgpiod introduction)

[gpiod_line_request_wait_edge_events example](https://github.com/pikvm/kvmd-fan/blob/48b2e8b158d425d2d3354fcd258236afdbb4c0a0/src/fan.c#L169)


## [WiringPi](https://github.com/WiringPi/WiringPi)

It works by accessing `/dev/gpiomem`, which could be done manually like in this code [mocking wiringPi](https://github.com/DougieLawson/RaspberryPi/blob/master/Unified_LCD/wP.c).

Comes with a nice CLI utility:

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

# Set pin 32 to PWM value 512 - half duty cycle
# PWM values: 0..1023
gpio pwm 26 512

# Set pin 31 (GPIO 6 / wPi 22) to Input pull-up mode
gpio mode 22 up
```


## PWM fan control basics

rPi [PWM basics](https://youngkin.github.io/post/pulsewidthmodulationraspberrypi/)

Fan control PWM base frequency is 25kHz (21kHz to 28kHz is acceptable) — [link](http://www.pavouk.org/hw/fan/en_fan4wire.html).

Mark-space mode is required.

[Balanced vs Mark-Space modes demonstration](https://www.instructables.com/RaspberryPi-Pulse-Width-Modulation-Demonstration/).

The BCM2835 PWM clock is [derived from a 19.2MHz clock](https://github.com/ondrej1024/shtlib/blob/master/bcm2835.h#L212).

[BCM2835 PWM clock dividers](https://github.com/ondrej1024/shtlib/blob/master/bcm2835.h#L1027)

rPi average output of the PWM channel is determined by the ratio of DATA/RANGE for that channel.

Quick example with wPi CLI:

```bash
# Set pin 32 (aka GPIO 12, aka wPi 26) to PWM mode
gpio mode 26 pwm

# Set the PWM mode to mark-space (default is pwm-bal)
gpio pwm-ms

# Set clock divider to 2 = half the 19.2 MHz crystal = 9.6 MHz
gpio pwmc 2

# Targeting 25kHz PWM freq, 1/25000 = 40 microseconds
# 40 microseconds * 9.6 MHz = 1/25000 * 9600000 = 384
# Set PWM period to 384 clocks
gpio pwmr 384

# Then a dutycycle of 96=25%, 192=50%, 288=75%, etc.
# Set half duty cycle:
gpio pwm 26 192

# Longer PWM periods, like 480 clocks, could produce audio interference, 
# because 480/9.6 MHz = 50 microseconds = 20 kHz (upper limit of the audible freq range)
```

Aditional:

[Short summary](https://raspberrypi.stackexchange.com/questions/53854/driving-pwm-output-frequency).

[Servo motors example](https://github.com/section77/pwm-gpio/blob/master/gpio-pwm.md) (not related to fan control).

[bcm2835 library PWM example](https://www.airspayce.com/mikem/bcm2835/pwm_8c-example.html)
