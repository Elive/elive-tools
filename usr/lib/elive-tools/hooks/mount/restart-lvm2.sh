#!/bin/bash

# NOTE: actually our thunar hacks doesn't seems to see when a device is unencrypted, only mounted

# restart lvm2 service
#######################
#   useful to show lvm2 devices after to mount a crypted fs, at least on live mode (sudo enabled)
if [[ -x "/etc/init.d/lvm2" ]] ; then
    if [[ "$UID" = 0 ]] ; then
        invoke-rc.d lvm2 start
    else
        # running as user (maybe in live)
        source /usr/lib/elive-tools/functions
        el_sudo invoke-rc.d lvm2 start
    fi
fi

exit 0

