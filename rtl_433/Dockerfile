#
# local/rtl_433 - an image with arm32v6/alpine:3.12 and current rtl_433.
#
# Sat Aug 07 00:13:53 PDT 2021 
# Stuart Lynne 
# 
# This will build an image for rtl_433 that works on the Raspberry Pi Zero W.
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


#FROM arm32v6/alpine:3.12 AS builder
FROM local/alpine AS builder

LABEL maintainer "Stuart Lynne <stuart.lynne@gmail.com>"

RUN apk add --no-cache \
    build-base \
    cmake \
    git \
    librtlsdr-dev

ARG RTL_433_TAG=master

ENV RTL_433_TAG=$RTL_433_TAG

RUN git clone https://github.com/merbanan/rtl_433.git /tmp/rtl_433 \
  && cd /tmp/rtl_433 \
  && git checkout $RTL_433_TAG \
  && mkdir build \
  && cd build \
  && cmake .. \
  && make

##############
# Main image #
##############

#FROM arm32v6/alpine:3.12
FROM local/alpine

RUN apk add --no-cache rtl-sdr

COPY --from=builder /tmp/rtl_433/build/src/rtl_433 /usr/local/bin/rtl_433
COPY --from=builder /tmp/rtl_433/conf/*.conf /usr/local/etc/rtl_433/
COPY --from=builder /tmp/rtl_433/include/rtl_433*.h /usr/local/include/

ENTRYPOINT ["rtl_433"]

