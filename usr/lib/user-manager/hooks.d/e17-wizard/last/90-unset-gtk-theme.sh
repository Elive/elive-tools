#!/bin/sh

# wizard is finished, we don't need a default gtk settings anymore
if [ -n "$EROOT" ] ; then
    killall xsettingsd 2>/dev/null 1>&2 || true
fi
