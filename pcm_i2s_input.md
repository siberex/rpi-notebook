# I2S input

Master device connection (i.e. connected PCM output device should provide BCLK).

[Connect pins](https://pinout.xyz/pinout/pcm):

- GND
- BCLK: GPIO 18
- FS: GPIO 19
- DATA_IN: GPIO 20


Edit `/boot/firmware/config.txt`:

```conf
# PCM pins function enable:
dtparam=i2s=on
# Enable audio (loads snd_bcm2835)
dtparam=audio=on

# Enable either one of "soundcard" dtoverlays to get I2S audio input:

# Option 1.
# arecord -vv --device=plughw:CARD=sndrpigooglevoi,DEV=0
dtoverlay=googlevoicehat-soundcard

# Option 2.
# arecord -vv --device=plughw:CARD=tc358743,DEV=0
# Note: tc358743-audio requires tc358743 dtoverlay to be loaded.
dtoverlay=tc358743
dtoverlay=tc358743-audio
```

Verify:

```bash
arecord --list-devices
# Expected output for tc358743-audio devicetree overlay:
# card 2: tc358743 [tc358743], device 0: 1f000a4000.i2s-dir-hifi dir-hifi-0 [1f000a4000.i2s-dir-hifi dir-hifi-0]

# Expected output for googlevoicehat-soundcard devicetree overlay:
# card 2: sndrpigooglevoi [snd_rpi_googlevoicehat_soundcar], device 0: Google voiceHAT SoundCard HiFi voicehat-hifi-0 [Google voiceHAT SoundCard HiFi voicehat-hifi-0]
```


Note:
The `sndrpigooglevoi` card can only accept FS=48kHz with S32_LE word length:

https://github.com/raspberrypi/linux/blob/23e6672404e861634632f17e9d3253d265cc8186/sound/soc/bcm/googlevoicehat-codec.c#L136

See also: https://github.com/zhaofengli/googlevoicehat


## Record

Could not get `sndrpigooglevoi` to work with rPi5 — soundcard detected, but recording is useless noise at 50% VU meter.

`tc358743-audio` works:

```bash
arecord -vv \
    --device=plughw:CARD=tc358743,DEV=0 \
    --rate=48000 \
    --channels=2 \
    --format=S32_LE \
    --duration=10 test_48000_S32.wav

# Wrong number of channels and format, transformation table will be applied:
arecord -vv \
    --device=plughw:CARD=tc358743,DEV=0 \
    --rate=48000 \
    --channels=1 \
    --format=FLOAT_LE \
    --duration=10 test_48000_FLOAT.wav
```



# I2S Output

Check out dtoverlays:

```bash
dtoverlay=i2s-master-dac
dtoverlay=max98357a,no-sdmode
```
