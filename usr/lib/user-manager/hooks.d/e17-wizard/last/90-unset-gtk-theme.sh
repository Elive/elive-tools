#!/bin/sh

if [[ -n "$ESTART" ]] ; then
    killall xsettingsd 2>/dev/null 1>&2 || true
fi
