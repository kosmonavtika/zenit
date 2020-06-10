#!/usr/bin/env bash

SECONDS=0

docker build . -t mark7-firmware && \
docker run --rm -v "$PWD/artifacts:/tmp/artifacts" mark7-firmware:latest

echo
echo "kosmos reader firmware built in $SECONDSs!"
echo "use \`./flash.sh <target mountpoint> <ssh key>\` to flash device"
