#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later

# Compilation-script for nightly builds.
# Should be copied to a private location (~/bin), so that
# git changes to that script can be reviewed before.
#
# Expects the Maxima git checkout in ~/maxima-code
#
# Calling from a cronjob does not work (don't know why),
# so call it from a screen session (which you can detach)
# and do everything in a loop.


buildinformation () {
    echo "Build information"
    echo "-----------------"
    echo
    echo "Operating system: "
    lsb_release  -d
    echo -n "Maxima GIT Version: "
    git describe
    echo -n "Wxmaxima GIT Version: "
    git -C wxmaxima/wxmaxima-git-prefix/src/wxmaxima-git describe
    echo -n "Build date and time (UTC): "
    date --utc
    echo
    echo
}

# Should be called as buildprocess win32 or buildprocess win64
buildprocess () {
    rm -rf -- *
    echo "$1 build log:"
    if [ "$1" == "win64" ]
    then
        $CMAKE -DBUILD_CURRENT=YES -DWITH_ABCL=NO -DBUILD_64BIT=YES ..
    else
        $CMAKE -DBUILD_CURRENT=YES -DWITH_ABCL=NO -DBUILD_64BIT=NO ..
    fi
    make
    make package
    echo
    echo
    buildinformation
    cp maxima-current-*.exe ~
}

# sleep until a given time
sleepuntil () {
    sleep $(( (24*60*60 + $(date -d "$1" +%s) - $(date +%s) ) % (24*60*60) ))
}

# do everything in English:
LANG=C
export LANG

CMAKE=/usr/bin/cmake

test -x $CMAKE || exit

mkdir build
cd build || exit
buildprocess "win64" 2>&1 | tee ~/buildlog-win64
