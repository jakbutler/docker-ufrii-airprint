# docker-ufrii-airprint

Based on  [aadl/cups](https://github.com/aadl/docker-cups) with support for Cannon UFR II (UFR2) drivers and AirPrint added. 

# What is CUPS?

CUPS is an open source printing system that supports IPP along with other protocols. More information can be found at [cups.org](http://cups.org/)

# About this image

This image is built on top of [aadl/cups](https://github.com/aadl/docker-cups), which uses CUPS v2.2.1 and installs v3.5.0 of the Canon UFR II drivers. 

# Running this image

```bash
docker run -e CUPS_USER_ADMIN=admin -e CUPS_USER_PASSWORD=secr3t -p 6631:631/tcp jakbutler/docker-ufrii-airprint
```