#!/usr/bin/env bash
READER_TARGET=$1
READER_SSH_KEY=$2

rm -rfv $1/.kosmos
rm -fv $1/.kobo/KoboRoot.tgz

mkdir -pv $READER_TARGET/.kosmos/
cp -vrf template/* $READER_TARGET/.kosmos/
cp -vrf artifacts/root/* $READER_TARGET/.kosmos/
cp -vrf artifacts/vendor/* $READER_TARGET/.kobo/
