#!/bin/bash


. ./config.env

export RTL_433_IMAGE=rtl_433:alpine-latest
export TELEGRAF_IMAGE=mik9/telegraf-latest

docker-compose -f docker-compose.yml up -d

