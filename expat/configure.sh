#!/bin/sh
# configure.sh --
#

set -ex

prefix=/usr/local
if test -d /lib64
then libdir=${prefix}/lib64
else libdir=${prefix}/lib
fi

../configure \
    --enable-maintainer-mode			\
    --config-cache				\
    --cache-file=../config.cache		\
    --disable-static --enable-shared            \
    --prefix="${prefix}"			\
    --libdir="${libdir}"                        \
    CFLAGS='-O3'				\
    "$@"

### end of file
