FROM alpine:edge

MAINTAINER jakbutler

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################
ENV DRIVER_URL='http://gdlp01.c-wss.com/gds/6/0100009236/01/linux-UFRII-drv-v350-usen.tar.gz'
# ENV CUPS_USER_ADMIN=admin
# ENV CUPS_USER_PASSWORD=secr3t

#########################################
##         DEPENDENCY INSTALL          ##
#########################################
RUN apk add --update --no-cache --repository=https://s3.amazonaws.com/aadl-github/alpine \
	cups cups-pdf cups-filters cups-dev cups-libs 'cups<2.2.7' --allow-untrusted && \
	sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

RUN apk update && \
    apk add --no-cache --upgrade \
    curl \
    tar \
    dpkg \
    bash \
    autoconf \
    automake \
    glib \
    libglade \
    libxml2 \
    ghostscript \
    gtk+ \
    libc6-compat \
    libstdc++ \
    # libglade-dev \
    # pango \
    # libpng \
    inotify-tools \
    python \
    python-dev \
    py-pip \
    build-base

#########################################
##            Script Setup             ##
#########################################
COPY start-cups.sh /root/start-cups.sh
RUN chmod +x /root/start-cups.sh
COPY printer-update.sh /root/printer-update.sh
RUN chmod +x /root/printer-update.sh

## Install and configure AirPrint
RUN pip install pycups
RUN wget --no-check-certificate https://raw.github.com/tjfontaine/airprint-generate/master/airprint-generate.py -P /root/
RUN chmod +x /root/airprint-generate.py

## Add proper mimetypes for iOS
COPY mime/airprint.convs /share/cups/mime/airprint.convs
COPY mime/airprint.types /share/cups/mime/airprint.types

## Install Canon URFII drivers
RUN touch /var/lib/dpkg/status
 #&& cp /var/lib/dpkg/available-old /var/lib/dpkg/available
RUN curl $DRIVER_URL | tar xz
RUN dpkg --force-all -i linux-UFRII-drv-v350-usen*/64-bit_Driver/Debian/*common*.deb
RUN dpkg --force-all -i linux-UFRII-drv-v350-usen*/64-bit_Driver/Debian/*ufr2*.deb
RUN rm -rf linux-UFRII-drv-v350-usen*

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