# pitrtl - Raspberry PI RTL SDR monitor
# Fri Jul 30 13:54:38 PDT 2021

This documents implementing an RTL SDR monitor on a Raspberry PI Zero W using docker compose.

Goal:
- low cost
- use telegraf to manage influxdb server outages
- feed data to remote influxdb
- easy deployment using docker-compose

Hardware:
- Raspberry PI Zero W
- Nooelec NESDR Mini 
- 5V Mini-UPS

## Container Configuration

### Telegraf
Telegraf is configured using */etc/telegraf/telegraf.conf* file. This can be modified
using environment variables.

Currently:
    - INFLUXURL - address of the influxdb server
    - INFLUXDB - name of the influxdb database to use

#### Database

Typically INFLUXDB (set in .env) would be *sensors*.


### rtl_433

*rtl_433* is configured either through the */etc/rtl_433/rtl_433.conf* file. This can be
modified directly. Or either eliminated or set up as a minimal configuration and the 
required protocols and frequencies configured through the command arguements in the 
*docker-compose.yml* file.

As distributed the rtl_433.conf has all protocols commented out to minimize overhead. 
Set required protocols via the command line.

#### docker-compose.yml

rtl_433 protocol and frequency options can be set in *docker-compose.yml*:

```
    rtl_433:
        image: hertzg/rtl_433:latest
        container_name: rtl_433
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
        depends_on:
          - telegraf
```


## Network

Each *container* acts as a separate *host* for networking purposes. For example:

| hostname | ip address |
| -------- | ---------- |
| telegraf | 172.19.0.2 |
| rtl_433  | 172.19.0.3 |

Each container is configured independantly as a *host*. 

Typically INFLUXURL (set in .env) would be *http://influxhost.mydomain.com:8086*

```
    rtl_433 -> telegraf:8086 -> telegraf -> influxhost.mydomain.com:8086 -> influxdb host
```

Because *NAT reflection* is not implemented in most NAT routers, when testing this it
may be neccessary to set the local IP address within the same host or local network.

Local use, set in .env:

- production: INFLUXURL=http://influx4.wimsey.co:8086
- test: INFLUXURL=http://192.168.40.16:8086


