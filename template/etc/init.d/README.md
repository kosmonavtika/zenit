# `/etc/init.d`

Executable shell scripts placed in this directory will be executed on device initialization in alphabetical order.

```
run-parts runs all the executable files named within constraints described below, found in directory directory. Other files and directories are silently ignored.

If neither the --lsbsysinit option nor the --regex option is given then the names must consist entirely of ASCII upper- and lower-case letters, ASCII digits, ASCII underscores, and ASCII minus-hyphens.

If the --lsbsysinit option is given, then the names must not end in .dpkg-old or .dpkg-dist or .dpkg-new or .dpkg-tmp, and must belong to one or more of the following namespaces: the LANANA-assigned namespace (^[a-z0-9]+$); the LSB hierarchical and reserved namespaces (^_?([a-z0-9_.]+-)+[a-z0-9]+$); and the Debian cron script namespace (^[a-zA-Z0-9_-]+$).

If the --regex option is given, the names must match the custom extended regular expression specified as that option’s argument.

Files are run in the lexical sort order (according to the C/POSIX locale character collation rules) of their names unless the --reverse option is given, in which case they are run in the opposite order.
```
