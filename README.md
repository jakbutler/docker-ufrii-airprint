# docker-ufrii-airprint

Based on [debian:stretch-slim](https://hub.docker.com/_/debian), this docker image installs CUPS, enables Apple AirPrint and Google Cloud Print Connector, with support for the Cannon UFR II (UFR2) drivers. 

# What is CUPS?

CUPS is an open source printing system that supports IPP along with other protocols. More information can be found at [cups.org](http://cups.org/)

# About this image

This image installs CUPS v2.2.1, builds the most recent version of the Google Cloud Print Connector (1.16 as of last release), and installs v3.7.0 of the Canon UFR II drivers. The AirPrint configuration is accomplished using the helpful script created by [Timothy J Fontaine](https://github.com/tjfontaine/airprint-generate). 

# Usage

#### docker CLI
```bash
docker run -rm -d -e CUPS_USER_ADMIN=admin -e CUPS_USER_PASSWORD=secr3t \
    --name cups-ufrii --hostname cups \
    -p 137:137/udp -p 139:139/tcp -p 445:445/tcp -p 631:631/tcp -p 5353:5353/udp \
    -v /share/docker/cups/config:/etc/cups/:rw \
    -v /share/docker/cups/logs:/var/log/cups:rw \
    -v /share/docker/cups/cpc:/etc/cloud-print-connector:rw \
    jakbutler/ufrii-airprint:2.0.0
```

#### docker-compose
```yaml
version: "3"
services:
  cups:
    container_name: cups-ufrii
    hostname: cups
    image: jakbutler/ufrii-airprint:2.0.0
    restart: unless-stopped
    environment:
      CUPS_USER_ADMIN: admin
      CUPS_USER_PASSWORD: secr3t
    volumes:
      - /share/docker/cups/config:/etc/cups/:rw
      - /share/docker/cups/logs:/var/log/cups:rw
      - /share/docker/cups/cpc:/etc/cloud-print-connector:rw
    ports:
      - 137:137/udp
      - 139:139/tcp
      - 445:445/tcp
      - 631:631/tcp
      - 5353:5353/udp
```
## Parameters

The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side. 
For example with a volume `-v external:internal` - what this shows is the volume mapping from internal to external of the container.
So `-v ~/cups/config:/etc/cups/` would expose a folder from the user's home directory to be accessible from the container at the mount point `/etc/cups/`.

The below tables list the supported parameters for the container, not all of which are required. 

#### Environment Variables

| Variable  | Description  | Default  |
| --------  | -----------  | -------  |
| `TZ`  | The timezone to use for the container; useful for reading your log files. | `America/Los_Angeles` |   
| `CUPS_USER_ADMIN`  | The username that the cups web interface will use for Basic authentication. | `admin` |   
| `CUPS_USER_PASSWORD`  | The username that the cups web interface will use for Basic authentication. It is strongly recommended that you change this from the default.| `secr3t` |
| `CANON_DRIVER_URL`  | The location of the Canon UFRII drivers to install. | `http://gdlp01.c-wss.com/gds/8/0100007658/08/linux-UFRII-drv-v370-uken-05.tar.gz` |
| `CUPS_ENV_DEBUG`  | A boolean (0\|1) flag which, if true, will enable additional debug output to print to `stdout`. | `0`

#### Shared Volumes

| Volume  | Description |
| ------------- | ------------- |
| `/etc/cups/`  | (Required) The local directory where the cups configurations are stored. This is required to preserve any custom printer configurations you may add. |
| `/var/log/cups`  | (Optional) The local directory where the cups log files will be written.|
| `/root/cloud-print-connector/config`  | (Required) The local directory where the Google Cloud Print Connector configuration file is stored.  |

#### Configuring Google Cloud Print

Attach to the executing container. 
```bash
docker exec -it cups-ufrii /bin/bash
```
Navigate to the configuration directory for the cloud-print-connector and execute the configuration utility.  
```bash
cd /etc/cloud-print-connector
/opt/cloud-print-connector/gcp-connector-util init
```
You will be lead through a series of prompts, as below. Once complete, the configuration file will generate in the correct location. 
```
"Local printing" means that clients print directly to the connector via
local subnet, and that an Internet connection is neither necessary nor used.
Enable local printing?
y

"Cloud printing" means that clients can print from anywhere on the Internet,
and that printers must be explicitly shared with users.
Enable cloud printing?
y

Visit https://www.google.com/device, and enter this code. I'll wait for you.
XXX-XXX-XXX
Acquired OAuth credentials for robot account

Enter the email address of a user or group with whom all printers will automatically be shared or leave blank to disable automatic sharing:
user@example.com

The config file /gcp-cups-connector.config.json is ready to rock.
Keep it somewhere safe, as it contains an OAuth refresh token.
```
Restart the container to apply.

**Note**: You must map the `/etc/cloud-print-connector` directory on the container to a local directory on your host to ensure the configuration files persists after restart. 

## Install on unRaid
On unRaid, install from the **Community Repositories** and enter the required folder locations.

## Install on QNAP
On a QNAP, install using the Create Container page of **ContainerStation**. Search for *ufrii* and select the image from the **Docker Hub** tab and click **Create**. Specify the desired name and set the **Command** to `/root/start-cups.sh`. Adjust CPU and Memory limits as desired, then click on **Advanced Settings >>** to specify the environment variable and volume mappings. Click **Create** when done.   

## Versions
+ **2018-03-02:** Initial release.
+ **2019-04-27:** Updated with Google Cloud Print and newer Canon drivers. 