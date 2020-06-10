#!/usr/bin/env bash
docker build . -t mark7-firmware && \
docker run --rm -v "$PWD/artifacts:/tmp/artifacts" mark7-firmware:latest
