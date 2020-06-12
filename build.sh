#!/usr/bin/env bash

# TODO: force change root password

echo "zenit builder 0.0.1"
echo ""

SECONDS=0

[ -x "$(command -v docker)" ] || (echo "error: please install docker" && exit 1)

rm -rfv $PWD/artifacts/{root,vendor}
docker build . -t zenit-build && \
docker run --rm -v "$PWD/artifacts:/tmp/artifacts" zenit-build:latest && \
duration=$SECONDS && \
echo && \
echo "zenit built in ${duration}s" && \
echo "use install.sh <device mountpoint> <public ssh key> to install to device" || \
echo "ERROR: build failed"
