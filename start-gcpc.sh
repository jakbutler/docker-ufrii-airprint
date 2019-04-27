#!/usr/bin/env bash

### set password for root user ###
if [[ $(grep -ci admin /etc/shadow) -eq 0 ]]; then
    useradd admin --system -g lpadmin --no-create-home --password $(mkpasswd secr3t)
fi

### Prepare avahi-daemon configuration ###
sed -i 's/.*enable\-reflector=.*/enable\-reflector\=yes/' /etc/avahi/avahi-daemon.conf
sed -i 's/.*reflect\-ipv=.*/reflect\-ipv\=yes/' /etc/avahi/avahi-daemon.conf

### Start dbus
/etc/init.d/dbus start

### Start automatic printer refresh for avahi ###
/opt/airprint/printer-update.sh

### Start avahi instance ###
/etc/init.d/avahi-daemon start

sleep 10 && /opt/cloud-print-connector/gcp-cups-connector --config-filename /etc/cloud-print-connector/gcp-cups-connector.config.json &
