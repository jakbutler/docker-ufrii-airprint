FROM aadl/docker-cups-alpine

MAINTAINER jakbutler

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################
ENV DRIVER_URL='http://gdlp01.c-wss.com/gds/0/0100003440/12/Linux_UFRII_PrinterDriver_V330_us_EN.tar.gz'
# ENV CUPS_USER_ADMIN=admin
# ENV CUPS_USER_PASSWORD=secr3t

#########################################
##         DEPENDENCY INSTALL          ##
#########################################
RUN apk add --update --no-cache --repository=https://s3.amazonaws.com/aadl-github/alpine \
	cups cups-pdf cups-filters 'cups<2.2.4' --allow-untrusted && \
	sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

RUN apk update && \
    apk add --no-cache --upgrade \
    curl \
    dpkg \
    bash \
    autoconf \
    automake \
    libglade2-0 \
    libpango1.0-0 \
    libpng16-16 \
    inotify-tools \
    python-cups

#########################################
##            Script Setup             ##
#########################################
COPY start-cups.sh /root/start-cups.sh
RUN chmod +x /root/start-cups.sh
COPY printer-update.sh /root/printer-update.sh
RUN chmod +x /root/printer-update.sh

## Install Canon URFII drivers
RUN cd /tmp
RUN cd Linux_UFRII_PrinterDriver*/64-bit_Driver/Debian \
 && dpkg -i *common*.deb
RUN cd Linux_UFRII_PrinterDriver*/64-bit_Driver/Debian \
 && dpkg --force-all -i *ufr2*.deb

## Install and configure AirPrint
RUN wget --no-check-certificate https://raw.github.com/tjfontaine/airprint-generate/master/airprint-generate.py -P /root/
RUN chmod +x airprint-generate.py
RUN python airprint-generate.py

## Add proper mimetypes for iOS
COPY mime/airprint.convs /share/cups/mime/airprint.convs
COPY mime/airprint.types /share/cups/mime/airprint.types

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################
VOLUME /etc/cups/ \
       /etc/avahi/services/ \
       /var/log/cups \
       /var/spool/cups \
       /var/spool/cups-pdf \
       /var/cache/cups

#########################################
##           Startup Command           ##
#########################################
CMD ["/root/start-cups.sh"]

#########################################
##               PORTS                 ##
#########################################
EXPOSE 631