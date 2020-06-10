#
# build dropbear ssh
#

FROM ubuntu:20.04 as dropbear-build

# setup directories
RUN mkdir -pv /tmp/dropbear-build/toolchain \
    /tmp/dropbear-build/dropbear-arm \
    /tmp/dropbear-build/dropbear-x86 >> /tmp/log
WORKDIR /tmp/dropbear-build

# install toolchains
RUN apt-get update >> /tmp/log && \
    apt-get install -y wget tar xz-utils build-essential >> /tmp/log && \
    wget -O toolchain.tar.xz https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz >> /tmp/log && \
    tar xf /tmp/dropbear-build/toolchain.tar.xz -C /tmp/dropbear-build/toolchain --strip-components=1 >> /tmp/log

# download dropbear sources
RUN wget -O dropbear.tar.bz2 https://matt.ucc.asn.au/dropbear/releases/dropbear-2019.78.tar.bz2 >> /tmp/log && \
    tar xf /tmp/dropbear-build/dropbear.tar.bz2 -C /tmp/dropbear-build/dropbear-arm --strip-components=1 >> /tmp/log  && \
    tar xf /tmp/dropbear-build/dropbear.tar.bz2 -C /tmp/dropbear-build/dropbear-x86 --strip-components=1 >> /tmp/log

# build dropbear for armv7l
WORKDIR /tmp/dropbear-build/dropbear-arm
RUN export PATH=/tmp/dropbear-build/toolchain/bin:$PATH && \
    ./configure --host=arm-linux-gnueabihf --disable-zlib --enable-static >> /tmp/log && \
    make PROGRAMS='dropbear dropbearkey' MULTI=1 >> /tmp/log

# build dropbear for x86_64
WORKDIR /tmp/dropbear-build/dropbear-x86
RUN ./configure --disable-zlib --enable-static >> /tmp/log && \
    make PROGRAMS='dropbear dropbearkey' MULTI=1 >> /tmp/log

# generate dropbear keys
RUN ./dropbearmulti dropbearkey -t dss -f dss_key >> /tmp/log && \
    ./dropbearmulti dropbearkey -t rsa -f rsa_key >> /tmp/log && \
    ./dropbearmulti dropbearkey -t ecdsa -f ecdsa_key >> /tmp/log

#
# build dictionaries
#

FROM python:3.8-alpine as dict-build

# setup directories
RUN mkdir -pv /tmp/dict-build >> /tmp/log
WORKDIR /tmp/dict-build

# install dictionary builder and dependencies
RUN apk add alpine-sdk git >> /tmp/log && \
    git clone https://github.com/BoboTiG/ebook-reader-dict >> /tmp/log && \
    pip install --no-cache-dir -r ebook-reader-dict/requirements.txt >> /tmp/log

# build dictionaries
WORKDIR /tmp/dict-build/ebook-reader-dict
RUN python -m scripts --locale sv >> /tmp/log

#
# build firmware package
#

FROM alpine:latest

#
# TODO: replace urls with data retrieved from https://pgaskin.net/KoboStuff/kobofirmware.html
# TODO: add ignore to /mnt/onboard/.kosmos
#

# setup directories
RUN mkdir -pv /tmp/output/root/var/log \
    /tmp/output/root/etc/ssh \
    /tmp/output/root/bin \
    /tmp/output/vendor/dict \
    /tmp/output/firmware/root \
    /tmp/logs >> /tmp/log

# download firmware
WORKDIR /tmp/output/firmware
RUN apk add wget tar unzip curl gzip >> /tmp/log && \
    wget -O /tmp/output/firmware/archive.zip "https://kbdownload1-a.akamaihd.net/firmwares/kobo7/May2020/kobo-update-4.21.15015.zip" >> /tmp/log && \
    unzip /tmp/output/firmware/archive.zip >> /tmp/log && \
    rm -fv /tmp/output/firmware/archive.zip >> /tmp/log 

# extract firmware root filesystem
WORKDIR /tmp/output/firmware/root
RUN tar xfvz /tmp/output/firmware/KoboRoot.tgz >> /tmp/log

# copy build artifacts to container
COPY --from=dropbear-build /tmp/dropbear-build/dropbear-arm/dropbearmulti /tmp/output/root/bin/
COPY --from=dropbear-build /tmp/dropbear-build/dropbear-x86/*_key /tmp/output/root/etc/ssh/
COPY --from=dict-build /tmp/dict-build/ebook-reader-dict/data/sv/dicthtml-*.zip /tmp/output/vendor/dict/

# copy logs to container
COPY --from=dropbear-build /tmp/log /tmp/logs/dropbear-build.log
COPY --from=dict-build /tmp/log /tmp/logs/dict-build.log

# concatenate log
RUN export KOSMOS_BUILD_LOG="/tmp/output/root/var/log/build-$(date '+%F').log" && \
    echo "---------------------------------------------------------------" >> $KOSMOS_BUILD_LOG && \
    echo "kosmos reader build $(date)" >> $KOSMOS_BUILD_LOG && \
    echo "---------------------------------------------------------------" >> $KOSMOS_BUILD_LOG && \
    echo "dropbear ssh server build:" >> $KOSMOS_BUILD_LOG && \
    cat /tmp/logs/dropbear-build.log >> $KOSMOS_BUILD_LOG && \
    echo "" >> $KOSMOS_BUILD_LOG && \
    echo "dictionary build:" >> $KOSMOS_BUILD_LOG && \
    cat /tmp/logs/dict-build.log >> $KOSMOS_BUILD_LOG && \
    echo "" >> $KOSMOS_BUILD_LOG && \
    echo "firmware build:" >> $KOSMOS_BUILD_LOG && \
    cat /tmp/log >> $KOSMOS_BUILD_LOG && \
    echo "" >> $KOSMOS_BUILD_LOG && \
    gzip $KOSMOS_BUILD_LOG

CMD [ "cp", "-vrf", "/tmp/output/*", "/tmp/artifacts/" ]
