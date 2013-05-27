#!/bin/bash
#source /usr/lib/elive-tools/functions

# kill sucky process that doesn't allow us to umount devices
if top -b -n 1 | head -n 14 | tail -n 7  | grep -q tumblerd 2>/dev/null 1>/dev/null ; then
    killall tumblerd 2>/dev/null 1>/dev/null
    killall -9 tumblerd 2>/dev/null 1>/dev/null
fi

