

[WiringPi](https://github.com/WiringPi/WiringPi):

```bash
git clone https://github.com/WiringPi/WiringPi.git
cd WiringPi
./build debian

mv debian-template/wiringpi_3.2_arm64.deb .
sudo apt install ./wiringpi_3.2_arm64.deb

gpio readall
```

