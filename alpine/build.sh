#!/bin/bash


set -x

docker build -t local/alpine --build-arg TIMEZONE_ARG="America/Vancouver"  .

