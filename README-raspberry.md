# rtl\_433 on Raspbian
## stuart.lynne@gmail.com
## Fri Sep 17 18:49:38 PDT 2021 


There are three different issues that make getting an *rtl\_433* / *telegraf* container stack
working on *Raspbian*:

1. alpine:3.13 and newer cause rtl\_433 to crash.
2. rtl_433 older images have problems exiting and restarting on an async timeout.
3. finding a telegraf image that works correctly with Raspbian.

## alpine

A Dockerfile and build for an alpine:3.12 image that will work correctly for rtl\_433 on Raspbian.

There are two issues that need to be dealt with:

The there is a problem with Alpine 3.13 and newer that causes rtl\_433 to die with
this message:
```
   | Assertion failed: clock\_gettime(1, tp) == 0 (libusbi.h: usbi\_get\_monotonic\_time: 497)
```

*The alpine:3.12 version works correctly.*

Use build.sh to do or:
```
docker build -t local/alpine --build-arg TIMEZONE_ARG="America/Vancouver"  .
```
## rtl\_433

A Dockerfile and build for an rtl\_433 image that works correctly on Raspbian.

Versions of rtl\_433 prior to (about) 2021-02 have a bug that prevents rtl\_433
from exiting cleanly on some async timeouts. Current (2021-02 and newer) versions
have been fixed.

Use build.sh to do or:
```
docker build -t local/rtl_433 .
```

This can then be used in the pi\_rtl\_433 docker-compose.yml file to get a
working image for the Pi Zero W.


## mik9/telegraf:armv6

An image from mik9 that specifically supports raspbian.

