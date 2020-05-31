#!/bin/sh

# wizard is finished, we don't need a default gtk settings anymore
killall xsettingsd 2>/dev/null 1>&2 || true
