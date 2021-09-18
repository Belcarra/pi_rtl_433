#!/bin/bash
# build script for raspbian
# 

# Build the local versions of alpine and rtl_433
# See README-raspbian.md for details on why these are required.
#
(set -x; pushd alpine; ./build.sh)
(set -x; pushd rtl_433; ./build.sh)

set -x
. ./config.env
export RTL_433_IMAGE=local/rtl_433
export TELEGRAF_IMAGE=mik9/telegraf:armv6

docker-compose -f docker-compose.yml up -d

