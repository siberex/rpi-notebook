# Pico

Pico is a [RP2040](https://en.wikipedia.org/wiki/RP2040) microcontroller board

# SDK

```bash
brew install cmake
brew install --cask gcc-arm-embedded

mkdir $HOME/pico && cd $HOME/pico

git clone -b master --recurse-submodules https://github.com/raspberrypi/pico-sdk.git
git clone https://github.com/raspberrypi/pico-extras.git

export PICO_SDK_PATH=$HOME/pico/pico-sdk
export PICO_EXTRAS_PATH=$HOME/pico/pico-extras
```

Verify examples are built succesfully:

```bash
cd $HOME/pico
git clone https://github.com/raspberrypi/pico-examples.git
cd pico-examples

mkdir build && cd build
cmake ..

cd pwm/led_fade
make -j4
```


# [debugprobe](https://github.com/raspberrypi/debugprobe)

```bash
git clone https://github.com/raspberrypi/debugprobe
cd debugprobe
git submodule update --init
mkdir build && cd build

cmake -DDEBUG_ON_PICO=ON ..
make -j4

cp debugprobe_on_pico.uf2 /Volumes/RPI-RP2/
```

## Connections

![Pico as debugprobe connection](./debugprobe.png)

SWD:

```
GND -> GND
GP2 -> SWCLK
GP3 -> SWDIO
```

UART:

```
GP4/UART1 TX -> GP1/UART0 RX
GP5/UART1 RX -> GP0/UART0 TX
```

## Usage (UART)

```bash
ls /dev | grep usb
screen /dev/tty.usbmodem14302 115200
# Ctrl+A,Ctrl+\ to exit
```

Or with minicom:

```bash
brew install minicom

ls /dev | grep usb
minicom -b 115200 -D /dev/tty.usbmodem14302
# Esc+X to exit, Esc+Z for menu
```

## Usage (SWD)

Upload binaries

```bash
brew install openocd

# Proiduce elf file
make -j4

sudo openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000" -c "program blink.elf verify reset exit"
```

Debug with SWD

```bash
# Produce elf file with debug symbols
cmake -DCMAKE_BUILD_TYPE=Debug ..
make -j4

sudo openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000"
gdb blink.elf
```
