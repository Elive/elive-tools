#!/bin/sh

if [ -n "$E_START" ] ; then
    killall xsettingsd 2>/dev/null 1>&2 || true
fi
