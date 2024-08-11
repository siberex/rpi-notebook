# Network list

```bash
# Active connection profiles
ls -la /etc/NetworkManager/system-connections/
nmcli -p con show
nmcli connection show

# Device details
nmcli -p -f general,wifi-properties device show wlan0

# Active SSID info
nmcli device wifi list
iw dev wlan0 link

# Routes
ip route

# Change the route metric
sudo nmcli connection modify [id | name] ipv4.route-metric 123

# Disallow installing any default routes
sudo nmcli connection modify [id | name] ipv4.never-default yes ipv6.never-default yes

# Set static address
nmcli con mod eth0 ipv4.addresses 192.168.2.20/24
nmcli con mod eth0 ipv4.gateway 192.168.2.1
nmcli con mod eth0 ipv4.dns 8.8.8.8
```


# Unicode SSIDs convertion

Convert Unicode SSID to hex representation:

- [for wpa_supplicant.conf](https://raspberrypi.stackexchange.com/a/68661/162424)

- [for wpa_passphrase](https://superuser.com/a/1544279/1129367)

```bash
# 😈.putin.red → f09f98882e707574696e2e726564
echo -n "😈.putin.red" | od -t x1 -A n -w100000 | tr -d ' '

# 😈.putin.red → \xf0\x9f\x98\x88\x2e\x70\x75\x74\x69\x6e\x2e\x72\x65\x64
echo -n "😈.putin.red" | tr -d "\n" | od -A n -t x1 | sed 's/ /\\x/g'
wpa_passphrase $'\xf0\x9f\x98\x88\x2e\x70\x75\x74\x69\x6e\x2e\x72\x65\x64' testtest
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
    #ssid="😈.putin.red"
    # Do not put quotes in SSID in hex representation
	ssid=f09f98882e707574696e2e726564
    #psk="testtest"
	psk=bf550e21b661d8d52bac9cf2109718e4374a0a15ee9807c30a57fccf21255920
}

network={
	ssid="whatever_ssid"
	psk="password_plaintext"
}
```
