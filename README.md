# rtl\_433\_pi\_zero\_w - Raspberry Pi Zero W RTL 433
# Sat Aug 07 23:28:01 PDT 2021 
# Stuart.Lynne@belcarra.com
# 

This documents implementing an RTL 433 monitor on a Raspberry PI Zero W using docker compose.

We implement a simple container stack with two services:

- rtl\_433 - capture sensor data using a low cost Software Defined radio
- telegraf - buffer sensor data from rtl\_433 being sent to a remove influxdb server

Hardware:
- Raspberry PI Zero W
- Nooelec NESDR Mini or equivalent
- 5V Mini-UPS

### Configuration
See the config.env file:

- TZ - timezone
- INFLUXURL - URL to the influxdb server
- INFLUXDB - database name to use when sending data to the influxdb server
- RTL\_OPTIONS - configuration options for rtl\_433
- RTL\_PROTOCOLS - frequency and protocols for rtl\_433 to use

```
export TZ="America/Vancouver"
export INFLUXURL="http://influx4.wimsey.co:8086"
export INFLUXDB="sensors"
export RTL_OPTIONS="-F json -F 'influx://telegraf:8086/write?db=${INFLUXDB}' -M 'time:usec' -M 'level' -M 'stats:1' -M 'protocol' -R 113"
```

RTL protocols for 915Mhz Ambient TX-8300
```
# enable protocols: 113 - Ambient TX-8300
- export RTL_PROTOCOLS="-f 915M -R 113"
```

RTL protocols for 433Mhz, various
```
# enable protocols: 12 Oregon, 20 Ambient TFA, 40 - Accurite 5n1, 41 - Accurite 986, 165 - TFA
export RTL_PROTOCOLS="-R 12 -R 20 -R 40 -R 41 -R 165'"
```

### Telegraf
Telegraf is configured using */etc/telegraf/telegraf.conf* file. This can be modified
using environment variables.

Currently:
    - INFLUXURL - address of the influxdb server
    - INFLUXDB - name of the influxdb database to use

#### Database

Typically INFLUXDB (set in .env) would be *sensors*.


### rtl\_433

*rtl\_433* is configured either through the */etc/rtl\_433/rtl\_433.conf* file. This can be
modified directly. Or either eliminated or set up as a minimal configuration and the 
required protocols and frequencies configured through the command arguements in the 
*docker-compose.yml* file.

As distributed the rtl\_433.conf has all protocols commented out to minimize overhead. 
Set required protocols via the command line.


## Network

Each *container* acts as a separate *host* for networking purposes. For example:

| hostname | ip address |
| -------- | ---------- |
| telegraf | 172.19.0.2 |
| rtl\_433  | 172.19.0.3 |

Each container is configured independantly as a *host*. 

Typically INFLUXURL (set in .env) would be *http://influxhost.mydomain.com:8086*

```
    rtl\_433 -> telegraf:8086 -> telegraf -> influxhost.mydomain.com:8086 -> influxdb host
```

Because *NAT reflection* is not implemented in most NAT routers, when testing this it
may be neccessary to set the local IP address within the same host or local network.

Local use, set in .env:

- production: INFLUXURL=http://influx4.wimsey.co:8086
- test: INFLUXURL=http://192.168.40.16:8086


## Install - Raspbian

This will build the appropriate local images and then compose the containers for raspbian.

```
build-raspbian.sh
```

This build can take some time (minutes to hours for Pi 4 or Pi Zero).

## Install - generic

This will compose the contains for generic system (no local images):
```
build.sh
```

## Install Docker on Raspbian
```
curl -fsSL https://get.docker.com -o get-docker.sh
sh ./get-docker.sh
```
### Docker - convience script
```
pip3 docker-compose
```

### Docker Compose - pip3

## Logs

Add */etc/docker/daemon.json* file:
```
{
  "log-driver": "json-file",
  "log-opts": {"max-size": "10m", "max-file": "3"}
}
```


