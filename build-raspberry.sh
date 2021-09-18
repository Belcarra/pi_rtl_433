#!/bin/bash



#(set -x; pushd alpine; ./build.sh)
#(set -x; pushd; ./build.sh)

set -x
. ./config.env
export RTL_433_IMAGE=local/rtl_433
export TELEGRAF_IMAGE=mik9/telegraf:armv6

docker-compose -f docker-compose.yml up -d

