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
    tar xf /tmp/dropbear-build/dropbear.tar.bz2 -C /tmp/dropbear-build/dropbear-arm --strip-components=1 >> /tmp/log && \
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
# build nickelmenu
#

FROM geek1011/nickeltc:1.0 as nm-build

# setup directories and install dependencies
RUN mkdir -p /tmp/nm-build >> /tmp/log && \
    apt-get update >> /tmp/log && \
    apt-get install -y git >> /tmp/log

# clone nm git repository and patch nm config directory
WORKDIR /tmp/nm-build
RUN git clone https://github.com/geek1011/NickelMenu.git >> /tmp/log && \
    sed -i 's/NM_CONFIG_DIR \"\/mnt\/onboard\/.adds\/nm\"/NM_CONFIG_DIR \"\/mnt\/onboard\/Zenit\/etc\/nm\"/g' /tmp/nm-build/NickelMenu/src/config.h >> /tmp/log && \
    cat /tmp/nm-build/NickelMenu/src/config.h

# build nm
WORKDIR /tmp/nm-build/NickelMenu
RUN make clean >> /tmp/log && \
    make all koboroot NM_CONFIG_DIR="/mnt/onboard/Zenit/etc/nm" >> /tmp/log && \
    mkdir out && mv KoboRoot.tgz src/libnm.so out/

# extract compiled tgz
WORKDIR /tmp/nm-build/NickelMenu/out
RUN tar xfv KoboRoot.tgz >> /tmp/log


#
# build git client
#

FROM geek1011/nickeltc:1.0 as git-build

# setup directories and install dependencies
RUN mkdir -pv /tmp/git-build/toolchain \
    /tmp/git-build/build \
    /tmp/git-build/git >> /tmp/log

# install build tools
WORKDIR /tmp/git-build
RUN apt-get update >> /tmp/log && \
    apt-get install -y wget tar make autoconf libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev asciidoc xmlto >> /tmp/log

# download git sources
RUN wget -O git.tar.gz https://github.com/git/git/archive/v2.27.0.tar.gz >> /tmp/log && \
    tar xf /tmp/git-build/git.tar.gz -C /tmp/git-build/git --strip-components=1 >> /tmp/log

# build git
WORKDIR /tmp/git-build/git
RUN make \
        prefix=/tmp/git-build/build \
        HOST_CPU="armv7l" \
        NO_PERL=YesPlease \
        NO_EXPAT=YesPlease \
        NO_TCLTK=YesPlease \
        NO_GETTEXT=YesPlease \
        NO_PYTHON=YesPlease \
        NO_SVN_TESTS=YesPlaese \
        NO_OPENSSL=YesPlease \
        NO_CURL=YesPlease \
        NO_MSGFMT_EXTENDED_OPTIONS=YesPlease \
        CFLAGS="${CFLAGS} -static" \
    >> /tmp/log && \
    make prefix=/tmp/git-build/build install && \
    ls -latrR /tmp/git-build


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
# TODO: replace urls with data retrieved from https://pgaskin.net/KoboStuff/kobofirmware.html
# TODO: add ignore to /mnt/onboard/Zenit
#

FROM alpine:latest

# setup directories
RUN mkdir -pv /tmp/output/root/var/log \
    /tmp/output/root/etc/ssh \
    /tmp/output/root/bin \
    /tmp/output/vendor/dict \
    /tmp/output/firmware/root/root/.ssh \
    /tmp/artifacts \
    /tmp/logs >> /tmp/log

# download firmware
WORKDIR /tmp/output/firmware
RUN apk add wget tar unzip curl gzip >> /tmp/log && \
    wget -O /tmp/output/firmware/firmware.zip "https://kbdownload1-a.akamaihd.net/firmwares/kobo7/May2020/kobo-update-4.21.15015.zip" >> /tmp/log && \
    unzip /tmp/output/firmware/firmware.zip >> /tmp/log && \
    rm -fv /tmp/output/firmware/firmware.zip >> /tmp/log 

# extract firmware root filesystem
WORKDIR /tmp/output/firmware/root
COPY --from=nm-build /tmp/nm-build/NickelMenu/out/usr /tmp/output/firmware/root/usr
RUN tar xfvz /tmp/output/firmware/KoboRoot.tgz >> /tmp/log && \
    echo "/bin/sh /mnt/onboard/Zenit/bin/init" >> /tmp/output/firmware/root/etc/init.d/rcS && \
    chmod -R 700 /tmp/output/firmware/root/root/.ssh && \
    tar cvzf /tmp/output/vendor/KoboRoot.tgz --show-transformed --owner=root --group=root --mode="u=rwX,go=rX" . >> /tmp/log

# copy build artifacts to container
COPY --from=dropbear-build /tmp/dropbear-build/dropbear-arm/dropbearmulti /tmp/output/root/bin/
COPY --from=dropbear-build /tmp/dropbear-build/dropbear-x86/*_key /tmp/output/root/etc/ssh/
COPY --from=git-build /tmp/git-build/build/bin/* /tmp/output/root/bin/
COPY --from=dict-build /tmp/dict-build/ebook-reader-dict/data/sv/dicthtml-*.zip /tmp/output/vendor/dict/
RUN chmod a+x /tmp/output/root/bin/*

# copy logs to container
COPY --from=dropbear-build /tmp/log /tmp/logs/dropbear-build.log
COPY --from=nm-build /tmp/log /tmp/logs/nm-build.log
COPY --from=git-build /tmp/log /tmp/logs/git-build.log
COPY --from=dict-build /tmp/log /tmp/logs/dict-build.log

# concatenate log
RUN export ZENIT_BUILD_LOG="/tmp/output/root/var/log/build-$(date '+%F').log" && \
    echo "+-------------------------------------------------------------+" >> $ZENIT_BUILD_LOG && \
    echo " zenit build log $(date)" >> $ZENIT_BUILD_LOG && \
    echo "+-------------------------------------------------------------+" >> $ZENIT_BUILD_LOG && \
    echo "dropbear build:" >> $ZENIT_BUILD_LOG && \
    cat /tmp/logs/dropbear-build.log >> $ZENIT_BUILD_LOG && \
    echo "" >> $ZENIT_BUILD_LOG && \

    echo "nm build:" >> $ZENIT_BUILD_LOG && \
    cat /tmp/logs/nm-build.log >> $ZENIT_BUILD_LOG && \
    echo "" >> $ZENIT_BUILD_LOG && \

    echo "git build:" >> $ZENIT_BUILD_LOG && \
    cat /tmp/logs/git-build.log >> $ZENIT_BUILD_LOG && \
    echo "" >> $ZENIT_BUILD_LOG && \

    echo "dictionary build:" >> $ZENIT_BUILD_LOG && \
    cat /tmp/logs/dict-build.log >> $ZENIT_BUILD_LOG && \
    echo "" >> $ZENIT_BUILD_LOG && \

    echo "firmware build:" >> $ZENIT_BUILD_LOG && \
    cat /tmp/log >> $ZENIT_BUILD_LOG && \
    echo "" >> $ZENIT_BUILD_LOG && \
    gzip $ZENIT_BUILD_LOG

# extract artifacts
CMD cp -vrf /tmp/output/root /tmp/artifacts/root && cp -vrf /tmp/output/vendor /tmp/artifacts/vendor
