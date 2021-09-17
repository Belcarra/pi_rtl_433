# rtl\_433\_pi\_zero\_w - Raspberry Pi Zero W RTL 433
# Sat Aug 07 23:28:01 PDT 2021 
# Stuart.Lynne@belcarra.com
# 
This documents implementing an RTL 433 monitor on a Raspberry PI Zero W using docker compose.

Goal:
- low cost
- use telegraf to manage influxdb server outages
- feed data to remote influxdb
- easy deployment using docker-compose

Hardware:
- Raspberry PI Zero W
- Nooelec NESDR Mini or equivalent
- 5V Mini-UPS

## Known Issues
There are two extant problems:
1. alpine 3.13 and newer, Assertion failed: clock\_gettime(1, tp) == 0 (libusbi.h: usbi\_get\_monotonic\_time: 497)
2. rtl\_433, does not exit on async read failure, fixed 2021-01 approx

We need to build using the older *alpine:3.12* image and the latest *rtl_433* release.

This project will build two images that are then used by a docker-compose file to implement 
a container stack.

- local/alpine - image based on arm32v6/alpine:3.12
- local/rtl\_433 - image based on local/alpine with merbanana/rtl_433 installed
- pi_rtl_433 - container built to configure telegraf and rtl\_433 for local use


# local/alpine
A local alpine:3.12 image created for rtl\_433 to use. For ease in testing some additional
utilities (vim, bash, busybox-extras, timezone) are included.

# local/rtl\_433
A local rtl\_433 image is created for the pi\_rtl\_433 stack to use. This uses builds
on local/alpine to add the latest rtl_433 project and it's requirements.

#### alpine:3.12 required

#### rtl\_433:latest must be newer than 2021-02
A bug in rtl\_433 that prevented rtl\_433 from exiting on some async reads was fixed 2021-02. 




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

#### docker-compose.yml

rtl\_433 protocol and frequency options can be set in *docker-compose.yml*:

```
    rtl\_433:
        image: hertzg/rtl\_433:latest
        container\_name: rtl\_433
        restart: unless-stopped
        devices:
          - /dev/bus/usb:/dev/bus/usb
        command:
          # -f 433.92M | 915M
          - '-f' 
          - '915M'
          - '-f'
          - '433.92M'
          # -F kv | json
          - '-F'
          - 'json'
          # -F influx://localhost:38186 ...
          - '-F'
          - 'influx://localhost:38186/write?db=whiskey'
          # -M time:usec - time to micro-second
          - '-M'
          - 'time:usec'
          # -M level - rssi included
          - '-M'
          - 'level'
          # -M stats:1 - periodic stats for seen protocols
          - '-M'
          - 'stats:1'
          # -M protocol - protocol included
          - '-M' 
          - 'protocol'
          # -H 120 - set hop time
          - '-H'
          - '120'
          # -R 12 Oregon
          - '-R'
          - '12'
          # -R 20 Ambient TFA
          - '-R'
          - '20'
          # -R 40 - Accurite 5n1
          - '-R'
          - '40'
          # -R 41 - Accurite 986
          - '-R'
          - '41'
          # - R 112 - Ambient TX-8300
          - '-R'
          - '112'
        # wait until telegraf has started
        depends\_on:
          - telegraf
```


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


