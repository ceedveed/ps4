# Enable SSH
systemctl enable ssh
sed -i -- 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
/etc/init.d/ssh restart

sudo apt-get update
apt-get -y upgrade
apt-get -y install hostapd dnsmasq
systemctl unmask hostapd
systemctl stop dnsmasq
systemctl stop hostapd

cat << 'EOF' >> /etc/dhcpcd.conf
interface wlan0
static ip_address=192.168.4.1/24
nohook wpa_supplicant
EOF

sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig

cat << 'EOF' > /etc/dnsmasq.conf

# Disable DNS (We're using this for DHCP only)
port=0

# Disable resolv.conf and hosts File
no-resolv
no-hosts

# Filter Local Queries
domain-needed
bogus-priv

# Set Authoritative Mode
dhcp-authoritative

# Use the require wireless interface - usually wlan0
interface=wlan0

# Specify IP Range
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h

# Set Default DNS for DHCP
dhcp-option=6,192.168.4.1,192.168.4.1

# Set Default Gateway for DHCP
dhcp-option=3,192.168.4.1

EOF

cat << 'EOF' > /etc/hostapd/hostapd.conf
interface=wlan0
driver=nl80211
ssid=PS4-Exploit-Host
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2

# Password Host AP
wpa_passphrase=123456789
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

sed -i -- 's/#DAEMON_CONF=""/DAEMON_CONF="/etc/hostapd/hostapd.conf"/g' /etc/default/hostapd

sudo systemctl enable hostapd
sudo systemctl enable dnsmasq
sudo systemctl start hostapd
sudo systemctl start dnsmasq
sudo service dhcpcd restart

############################################PS4

curl -L https://github.com/Al-Azif/ps4-exploit-host/releases/download/v0.4.5/ps4-exploit-host-linux.arm-v0.4.5.zip --output /opt/ps4-exploit-host-linux.arm.zip
unzip -d /opt/ /opt/ps4-exploit-host-linux.arm.zip
rm /opt/ps4-exploit-host-linux.arm.zip
sed -i -- 's/"Interface_IP": ""/"Interface_IP": "192.168.4.1"/g' /opt/ps4-exploit-host/settings.json

cat << 'EOF' >> /opt/ps4-exploit-host/ps4-exploit-host.service
[Unit]
Description=PS4 Exploit Host
Wants=multi-user.target

[Service]
Type=simple
Restart=always
RestartSec=10
User=root
Group=root
WorkingDirectory=/opt/ps4-exploit-host
ExecStart=/opt/ps4-exploit-host/ps4-exploit-host
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

chmod +x /opt/ps4-exploit-host/ps4-exploit-host
ln -f /opt/ps4-exploit-host/ps4-exploit-host.service /lib/systemd/system/ps4-exploit-host.service

systemctl enable ps4-exploit-host
systemctl start ps4-exploit-host
