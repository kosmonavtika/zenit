# Zenit

**DISCLAIMER: Use at your own risk! This can potentially brick your device.**

Minimal firmware overlay for Kobo 7th generaton eBook readers.

## How it works

1. You run `build.sh` to build Zenit
2. Docker builds [Dropbear 🐻](https://github.com/mkj/dropbear)
3. Docker builds [nm](https://github.com/geek1011/NickelMenu)
4. Docker builds [git](https://git-scm.com)
5. Docker builds [dictionaries](https://github.com/BoboTiG/ebook-reader-dict)
6. Docker downloads and modifies official firmware
7. Docker combines built, downloaded and modified files (in `artifacts`) with Zenit template filesystem (in `template`)
8. You run `install.sh <device mountpoint> <public ssh key>` to install Zenit to your device

Zenit stores all of it's files the removable storage of the device, in `<device mountpoint>/Zenit` (`/mnt/onboard/Zenit` locally on the device).

## To do

* Harden firmware
    * Force use of keys for SSH access
    * Password protect root user and admin user
* Add `HTTP(S)` and/or `ODPS` based book synchronization
* Add article synchronization
* Allow for additional dictionaries

## Notes

1. [Firmware downloads](https://wiki.mobileread.com/wiki/Kobo_Firmware_Releases#Firmware_2)
2. [Registration fix](https://yingtongli.me/blog/2018/07/30/kobo-rego.html)
3. [Telnet root access](https://yingtongli.me/blog/2018/07/30/kobo-telnet.html)
4. [SSH access](https://yingtongli.me/blog/2018/07/30/kobo-ssh.html)
5. [Dictionaries #1](https://github.com/BoboTiG/ebook-reader-dict)
6. [Dictionaries #2](https://pgaskin.net/dictutil/)
7. [Menu](https://github.com/baskerville/plato/tree/master/contrib/NickelMenu)
