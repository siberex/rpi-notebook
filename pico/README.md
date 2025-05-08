# Pico

Pico is a [RP2040](https://en.wikipedia.org/wiki/RP2040) microcontroller board

# SDK

## Prerequisites

[Arm GNU Toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads):

```bash
xcode-select --install
brew install --cask gcc-arm-embedded
```

Debian / Ubuntu:

```bash
sudo apt install git tar cmake python3 build-essential gcc-arm-none-eabi libnewlib-arm-none-eabi libstdc++-arm-none-eabi-newlib g++
```

## Install SDK

```bash
brew install cmake
brew install --cask gcc-arm-embedded

mkdir $HOME/pico && cd $HOME/pico

git clone -b master --recurse-submodules https://github.com/raspberrypi/pico-sdk.git
git clone https://github.com/raspberrypi/pico-extras.git
git clone -b main --recurse-submodules https://github.com/FreeRTOS/FreeRTOS-Kernel.git
git clone https://github.com/pimoroni/pimoroni-pico.git

# Add to .bashrc
export PICO_SDK_PATH=$HOME/pico/pico-sdk
export PICO_EXTRAS_PATH=$HOME/pico/pico-extras
export FREERTOS_KERNEL_PATH=$HOME/pico/FreeRTOS-Kernel
export PIMORONI_PICO_PATH=$HOME/pico/pimoroni-pico
```

## Verify examples are built succesfully

```bash
cd $HOME/pico
git clone https://github.com/raspberrypi/pico-examples.git
cd pico-examples

mkdir build && cd build
cmake ..

cd cd $HOME/pico/pico-examples/build/pwm/led_fade
make -j4


cd cd $HOME/pico/pico-examples/build/freertos/hello_freertos
make -j4

cd $HOME/pico
mkdir build_rp2350 && cd build_rp2350

cmake .. -DPICO_BOARD=pico2


#universa; toddo
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
# screen /dev/ttyACM0 115200
# Ctrl+A,Ctrl+\ to exit
```

Or with minicom:

```bash
brew install minicom

ls /dev | grep usb
minicom -b 115200 -D /dev/tty.usbmodem14302
# minicom -b 115200 -D /dev/ttyACM0
# Esc+X to exit, Esc+Z for menu
```

Alternatives:

- [VSCode Serial Monitor plugin](https://marketplace.visualstudio.com/items?itemName=ms-vscode.vscode-serial-monitor)
- [CoolTerm](https://freeware.the-meiers.org)


## Usage (SWD)

### Upload binaries

```bash
brew install openocd

# Produce an elf file
# make -j4

sudo openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000" -c "program blink.elf verify reset exit"
```

### Debug with SWD

[GDB with MacOS](https://sourceware.org/gdb/wiki/PermissionsDarwin)

[LLDB](https://lldb.llvm.org/)

```bash
# Produce an elf file with the debug symbols
cmake -DCMAKE_BUILD_TYPE=Debug -DPICO_BOARD=pico ..
make -j4

# Run an OpenOCD server:
sudo openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000"

# Run debugger in another tab:
gdb blink.elf
> target remote localhost:3333
> monitor reset init
> continue

```


# [Picotool](https://github.com/raspberrypi/pico-sdk-tools/blob/main/packages/linux/picotool/build-picotool.sh)

```bash
# Prerequisites
brew install libusb pkg-config

# Build and install
cd $HOME/pico
git clone https://github.com/raspberrypi/picotool.git
cd picotool
mkdir build && cd build
cmake ..
make
sudo make install
```
