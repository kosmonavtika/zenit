#!/usr/bin/env bash

SECONDS=0
DEVICE_MOUNTPOINT=$1
DEVICE_SSH_KEY=$2
VOSTOK_ROOT="$DEVICE_MOUNTPOINT/Zenit"

[ -z DEVICE_MOUNTPOINT ] || echo "usage: install.sh <device mountpoint> <public ssh key>" && exit 1

rm -rfv $ZENIT_ROOT
rm -fv $1/.kobo/KoboRoot.tgz

mkdir -pv $ZENIT_ROOT
cp -vrf template/* $ZENIT_ROOT/
cp -vrf artifacts/root/* $ZENIT_ROOT/
cp -vrf artifacts/vendor/* $DEVICE_MOUNTPOINT/.kobo/

cat $DEVICE_SSH_KEY > $ZENIT_ROOT/etc/ssh/authorized_keys
chmod -R 600 $ZENIT_ROOT/etc/ssh/authorized_keys

duration=$SECONDS
echo
echo "zenit installed to \"$ZENIT_ROOT\"in ${duration}s"
