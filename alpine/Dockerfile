#
# local/alpine - an image with arm32v6/alpine:3.12 
#
# Sat Aug 07 00:13:53 PDT 2021 
# Stuart Lynne 
# 
# This will build an alpine:3.12 image for rtl_433 that works on the Raspberry Pi Zero W.
#
# There are two issues that need to be dealt with:
#
#   1. Getting a version of Alpine that works with arm32v6.
#   2. Getting a current version of rtl_433 that does not have the async timeout bug.
#
# The there is a problem with Alpine 3.13 and newer that causes rtl_433 to die with
# this message:
#    | Assertion failed: clock_gettime(1, tp) == 0 (libusbi.h: usbi_get_monotonic_time: 497)
# 
# The 3.12 version works correctly.
#
# Versions of rtl_433 prior to (about) 2021-02 have a bug that prevents rtl_433
# from exiting cleanly on some async timeouts. Current (2021-02 and newer) versions
# have been fixed.
#
# Use the build.sh to do:
#
#          docker build -t local/rtl_433 .
#
# to build the local/rtl_433 image. 
#
# This can then be used in the pi_rtl_433 docker-compose.yml file to get a
# working image for the Pi Zero W.
#


#FROM arm32v6/alpine:3.12 (linux/arm/v6) AS builder

FROM arm32v6/alpine:3.12 

LABEL maintainer "Stuart Lynne <stuart.lynne@gmail.com>"

ARG TIMEZONE_ARG="Europe/Paris"
ENV TIMEZONE=$TIMEZONE_ARG

RUN apk update
RUN apk add vim bash busybox-extras
RUN echo ****** Hello World
run env
RUN echo ****** TIMEZONE: $TIMEZONE
RUN echo ****** TIMEZONE_ARG: $TIMEZONE_ARG
RUN apk add tzdata \
    && echo TIMEZONE: $TIMEZONE > /etc/timezone \
    && cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && apk del tzdata
RUN cat /etc/timezone && date && uname -a && cat /etc/os-release

