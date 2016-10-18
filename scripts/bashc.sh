#! /bin/bash
[ $# -ne 2 ] && echo "usage: $0 <source.sh> <out.bin>" && exit 2
(cat "$0" "$1"; printf "#%020i" $(ls -l $1 | awk '{print $5}'); ) > "$2" &&
chmod 755 "$2"
