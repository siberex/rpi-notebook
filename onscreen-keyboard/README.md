The latest rPi OS (Bookworm) uses Wayland. It shipped without onscreen keyboard.

Most onscreen keyboards (like matchbox-keyboard) do not work with Wayland.

Install wvkbd to use with Wayland:

```bash
sudo apt install wvkbd

```

Install toggle script:

```bash
mkdir -p /home/pi/onscreen-keyboard/
cp toggle-wvkbd.sh /home/pi/onscreen-keyboard/
chmod +x /home/pi/onscreen-keyboard/toggle-wvkbd.sh
sudo cp keyboard.png /usr/share/icons/hicolor/512x512/apps/
sudo cp wvkbd.desktop /usr/share/applications/
```

Add launcher icon to the `~/.config/wf-panel-pi.ini`

```bash
launcher_000004=wvkbd.desktop
```



@TerribleTed Oct 2023

update: you can set up wayfire to invoke the OSK using the mouse button.
i figured out how to invoke the on-screen keyboard using the MIDDLE (scroll-wheel) button.
ADD this to wayfire.ini

binding_osk = BTN_MIDDLE
command_osk = /home/pi/onscreen-keyboard/toggle-wvkbd.sh

NOTE: the binding can be BTN_LEFT, BTN_RIGHT or BTN_MIDDLE
took some digging, but it works ! (at least on my PI4-8G with Bookworm.)
YMMV

So, a kiosk user can click the middle mouse button to bring up the OSK

