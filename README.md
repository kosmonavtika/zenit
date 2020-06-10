# Kosmos Reader

Minimal firmware overlay for Kobo Mk7 eBook readers.

**DISCLAIMER: Use at your own risk! This can potentially brick your device.**

## How it works

1. You run `build.sh` to build Kosmos Reader
2. Docker builds [Dropbear](https://github.com/mkj/dropbear)
3. Docker builds [dictionaries](https://github.com/BoboTiG/ebook-reader-dict)
4. Docker downloads and modifies official firmware
5. Docker combines built, downloaded and modified files (in `artifacts`) with Kosmos Reader template filesystem (in `template`)
6. You run `flash.sh <device mountpoint> <ssh key>` to flash your device

## To do

* Harden firmware
    * Force use of keys for SSH access
    * Delete users
    * Password protect root user
    * Remove serial console access
* Add SSH on/off switch to menu
* Add browser to main menu
* Add `HTTP(S)` and/or `ODPS` based book synchronization
* Make activation less intrusive (don't use `/etc/init.d/rcS`)
    * Use `udev/rules.d`?
* Add additional dictionaries
* Add article synchronization

## Notes

1. [Firmware downloads](https://wiki.mobileread.com/wiki/Kobo_Firmware_Releases#Firmware_2)
2. [Registration fix](https://yingtongli.me/blog/2018/07/30/kobo-rego.html)
3. [Telnet root access](https://yingtongli.me/blog/2018/07/30/kobo-telnet.html)
4. [SSH access](https://yingtongli.me/blog/2018/07/30/kobo-ssh.html)
5. [Dictionaries #1](https://github.com/BoboTiG/ebook-reader-dict)
6. [Dictionaries #2](https://pgaskin.net/dictutil/)
7. [Menu](https://github.com/baskerville/plato/tree/master/contrib/NickelMenu)
