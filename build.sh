#!/usr/bin/env bash

SECONDS=0

rm -rfv $PWD/artifacts/{root,vendor}
docker build . -t kosmos-reader && \
docker run --rm -v "$PWD/artifacts:/tmp/artifacts" kosmos-reader:latest && \
duration=$SECONDS && \
echo && \
echo "kosmos reader built in ${duration}s" && \
echo "use ./flash.sh <target mountpoint> <ssh key> to flash device" || \
echo "ERROR: build failed"
