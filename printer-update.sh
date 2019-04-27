#!/usr/bin/env bash

inotifywait -m -e close_write,moved_to,create /etc/cups |

while read -r directory events filename; do
	if [[ "$filename" = "printers.conf" ]]; then
        rm -rf /etc/avahi/services/AirPrint-*.service
		/opt/airprint/airprint-generate.py -d /etc/avahi/services
		# rm -rf /services/AirPrint-*.service
        # /opt/airprintot/airprint-generate.py -d /services
        # cp /etc/cups/printers.conf /config/printers.conf
        # rsync -avh /services/ /etc/avahi/services/
	fi
done