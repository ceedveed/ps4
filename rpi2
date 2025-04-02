#!/bin/bash

apt-get update
apt-get -y upgrade

curl -L https://github.com/Al-Azif/ps4-exploit-host/releases/download/v0.4.6a1/ps4-exploit-host-linux.arm-v0.4.6a1.zip --output /opt/ps4-exploit-host-linux.arm.zip

apt-get -y install dnsmasq

systemctl stop dhcpcd
systemctl stop dnsmasq

cat << 'EOF' >> /etc/dhcpcd.conf
interface eth0
static ip_address=192.168.1.1/24
denyinterfaces eth0
EOF

cat << 'EOF' > /etc/dnsmasq.conf
# Disable DNS (We're using this for DHCP only)
port=0

# Disable resolv.conf and hosts File
no-resolv
no-hosts

# Filter Local Queries
domain-needed
bogus-priv

# Bind to eth0
interface=eth0
bind-interfaces

# Set Default Gateway for DHCP
dhcp-option=3,192.168.1.1

# Set Default DNS for DHCP
dhcp-option=6,192.168.1.1,192.168.1.1

# Specify IP Range
dhcp-range=192.168.1.2,192.168.1.254,255.255.255.0,2h

# Set Authoritative Mode
dhcp-authoritative
EOF

unzip -d /opt/ /opt/ps4-exploit-host-linux.arm.zip
rm /opt/ps4-exploit-host-linux.arm.zip

sed -i -- 's/"Interface_IP": ""/"Interface_IP": "192.168.1.1"/g' /opt/ps4-exploit-host/settings.json

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

systemctl enable ssh
systemctl enable dhcpcd
systemctl enable dnsmasq
systemctl enable ps4-exploit-host

reboot
