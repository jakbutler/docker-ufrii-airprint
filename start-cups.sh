#!/usr/bin/env bash

### Enable debug if debug flag is true ###
if [[ -n "${CUPS_ENV_DEBUG}" ]]; then
    set -e
    set -x
fi

### Copy CUPS docker env variable to script ###
if [[ -z ${CUPS_USER_PASSWORD} ]]; then
  CUPS_PASSWORD="password"
else
  CUPS_PASSWORD=${CUPS_USER_PASSWORD}
fi

### Main logic to create an admin user for CUPS ###
if printf '%s' "${CUPS_PASSWORD}" | LC_ALL=C grep -q '[^ -~]\+'; then
  RETURN=1; REASON="CUPS password contain illegal non-ASCII characters, aborting!"; exit;
fi

### set password for root user ###
if [[ $(grep -ci ${CUPS_USER_ADMIN} /etc/shadow) -eq 0 ]]; then
    useradd ${CUPS_USER_ADMIN} --system -g lpadmin --no-create-home --password $(mkpasswd ${CUPS_PASSWORD})
    if [[ ${?} -ne 0 ]]; then RETURN=${?}; REASON="Failed to set password ${CUPS_PASSWORD} for user root, aborting!"; exit; fi
fi

### Use the default configurations if none present
if [[ $(find /etc/cups -type f | wc -l) -eq 0 ]]; then
    echo "Applying default containerized CUPS configuration."
    cp -R /usr/etc/cups/* /etc/cups/
fi

### Start dbus
/etc/init.d/dbus start

### Prepare avahi-daemon configuration ###
sed -i 's/.*enable\-reflector=.*/enable\-reflector\=yes/' /etc/avahi/avahi-daemon.conf
sed -i 's/.*reflect\-ipv=.*/reflect\-ipv\=yes/' /etc/avahi/avahi-daemon.conf
### Start automatic printer refresh for avahi ###
/opt/airprint/printer-update.sh &

### Start avahi instance ###
/etc/init.d/avahi-daemon start

### Start the Google Cloud Print Connector ###
if [[ -f /tmp/cloud-print-connector.sh-monitor.sock ]]; then
    rm /tmp/cloud-print-connector.sh-monitor.sock
fi
/etc/init.d/cloud-print-connector start

cat <<EOF
===========================================================
The dockerized CUPS instance is now ready for use! The web
interface is available here:
URL:       http://localhost:631/
Username:  ${CUPS_USER_ADMIN}
Password:  ${CUPS_PASSWORD}
===========================================================
EOF

### Start CUPS instance ###
/usr/sbin/cupsd -f