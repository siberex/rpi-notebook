
Status all pins:

```bash
sudo raspi-gpio get
```


[WiringPi](https://github.com/WiringPi/WiringPi):

```bash
git clone https://github.com/WiringPi/WiringPi.git
cd WiringPi
./build debian

mv debian-template/wiringpi_3.2_arm64.deb .
sudo apt install ./wiringpi_3.2_arm64.deb

gpio readall
```


See also: [man gpio](https://github.com/WiringPi/WiringPi/blob/master/gpio/gpio.1)


Example:

```bash
# Set pin 32 (aka GPIO 12, aka wPi 26) to PWM mode
gpio mode 26 pwm
# Set pin 32 to PWM value 512 - half brightness
# PWM values: 0..1023
gpio pwm 26 512

# Set pin 31 (GPIO 6 / wPi 22) to Input pull-up mode
gpio mode 22 up
```

