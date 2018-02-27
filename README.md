# docker-ufrii-airprint

Modeled after [aadl/cups-alpine](https://github.com/aadl/docker-cups-alpine/blob/master/2.2.3/start-cups.sh) with support for Cannon URFII drivers and AirPrint support added. 

# What is CUPS?

CUPS is an open source printing system that supports IPP along with other protocols. More information can be found at [cups.org](http://cups.org/)

# About this image

This image is based off Alpine linux to keep the size small. It is further modeled after [aadl/cups-alpine](https://github.com/aadl/docker-cups-alpine/blob/master/2.2.3/start-cups.sh)  

There is a custom cups-pdf package version 2.6.1 in the image from the aadl S3 repo.

# Running this image

```bash
docker run -e CUPS_USER_ADMIN=admin -e CUPS_USER_PASSWORD=secr3t -p 6631:631/tcp jakbutler/docker-ufrii-airprint
```