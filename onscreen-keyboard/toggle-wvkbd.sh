#!/usr/bin/env bash
# Script to toggle virtual keyboard
# /home/pi/onscreen-keyboard/toggle-wvkbd.sh
PID="$(pidof wvkbd-mobintl)"
if [  "$PID" != ""  ]; then
  killall wvkbd-mobintl
else
  # Use `wvkbd-mobintl --list-layers` to get the list of available layers.
  # Skip --landscape-layers to allow onscreen keyboard to cycle through all
  # Add -fn 40 to set font size
  # Use `wvkbd-mobintl --help` for options
  wvkbd-mobintl -L 300 --landscape-layers full,special
fi
