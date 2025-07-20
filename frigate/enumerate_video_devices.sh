#!/bin/bash

# Note: rPi5 does NOT have H264/H265 hardware encoding support
# https://forums.raspberrypi.com/viewtopic.php?t=378329

# rPi4 should provide /dev/video11, check for H264:

# shellcheck disable=SC2012
for num in $(ls -c1 /dev/video* | sed 's|/dev/video||'); do
    v4l2-ctl --list-formats-ext -d "$num"
done


# rPi5: Test HEVC hardware decoding with ffmpeg
# https://repo.jellyfin.org/test-videos/ or https://repo.jellyfin.org/archive/jellyfish/ (use jellyfish-3-mbps-hd-hevc.mkv)
ffmpeg -hwaccel drm -i "Test Jellyfin 1080p HEVC 8bit 3M.mp4" -hide_banner -f null -
# Expected output:
# ...
# [hevc @ 0x559641e540] Hwaccel V4L2 HEVC stateless V4; devices: /dev/media3,/dev/video19; buffers: src DMABuf, dst DMABuf; swfmt=rpi4_8
# ...


