# Unicode SSIDs convertion

Convert Unicode SSID to hex representation:

- [for wpa_supplicant.conf](https://raspberrypi.stackexchange.com/a/68661/162424)

- [for wpa_passphrase](https://superuser.com/a/1544279/1129367)

```bash
# 😇.putin.red → f09f98872e707574696e2e726564
echo -n "😇.putin.red" | od -t x1 -A n -w100000 | tr -d ' '

# 😇.putin.red → \xf0\x9f\x98\x87\x2e\x70\x75\x74\x69\x6e\x2e\x72\x65\x64
echo -n "😇.putin.red" | tr -d "\n" | od -A n -t x1 | sed 's/ /\\x/g'
wpa_passphrase $'\xf0\x9f\x98\x87\x2e\x70\x75\x74\x69\x6e\x2e\x72\x65\x64' testtest
```

# wpa_supplicant

```bash
# Scan available SSIDs
wpa_cli scan
wpa_cli scan_results
# OR:
# sudo iwlist wlan0 scan | grep ESSID

# Interactive password encoding:
wpa_passphrase 'YourSSID'

# WiFi config:
sudo vim /etc/wpa_supplicant/wpa_supplicant.conf
```

```conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    #ssid="😇.putin.red"
    # Do not quotes in ssid in hex representation
	ssid=f09f98872e707574696e2e726564
    #psk="testtest"
	psk=aced39b3bb662ba1013acecf4b335b0d12b276fbd3b12d3e044917471c256dba
}

network={
	ssid="whatever_ssid"
	psk="password_plaintext"
}
```
