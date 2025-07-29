## Bootloader (rPi4, rPi5)

Update bootloader:

```bash
sudo rpi-eeprom-update
```

Edit config:

```bash
sudo rpi-eeprom-config --edit
```

```ini
[all]
BOOT_UART=1
WAKE_ON_GPIO=0
POWER_OFF_ON_HALT=1
PSU_MAX_CURRENT=5000
DISABLE_HDMI=1
```

- `BOOT_UART=1`: Enable UART debug output on GPIO 14 and 15.

- `WAKE_ON_GPIO=0` and `POWER_OFF_ON_HALT=1`: `sudo halt` will switch off all PMIC outputs (lowest possible power state).

- `PSU_MAX_CURRENT=5000` (rPi5 only): Explicitly tell bootloader PSU is capable of delivering 5A.

    [Required for PoE hats](https://github.com/geerlingguy/raspberry-pi-pcie-devices/issues/597#issuecomment-2155709427), otherwise you will get `This power supply is not capable of supplying 5A` error.

- `DISABLE_HDMI=1`: Disable HDMI boot diagnostics display

- `BOOT_ORDER=0xf164`: Boot priority: try USB MSD (0x6), then NVME (0x4), then MicroSD (0x1), then reset (0xf)


Verify max current setting:

```bash
# Read negotiated PD value directly
od -t u4 --endian=big /proc/device-tree/chosen/power/max_current

# Or, with device tree:
dtc /proc/device-tree/chosen/power -f
# Should print max_current = <0x1388>;
printf "%d\n" 0x1388
```

## Docs

[Raspberry Pi bootloader configuration](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#raspberry-pi-bootloader-configuration)

[Decrease Raspberry Pi 5 wattage when turned off](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#decrease-raspberry-pi-5-wattage-when-turned-off)

[Raspberry Pi boot EEPROM](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#raspberry-pi-boot-eeprom)

[https://github.com/raspberrypi/rpi-eeprom](rpi-eeprom utils)

