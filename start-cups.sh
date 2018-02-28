#!/usr/bin/env sh
set -e
set -x

if [ $(grep -ci $CUPS_USER_ADMIN /etc/shadow) -eq 0 ]; then
    useradd $CUPS_USER_ADMIN --system -G root,lpadmin --no-create-home --password $(mkpasswd $CUPS_USER_PASSWORD)
fi

sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
sed -i 's/DefaultEncryption Basic/DefaultEncryption Never/' /etc/cups/cupsd.conf

/etc/init.d/dbus start
/etc/init.d/avahi-daemon start
/root/printer-update.sh &
exec /usr/sbin/cupsd -f