#!/bin/bash
source /usr/lib/elive-tools/functions

main(){
    # pre {{{
    #local file dir temp

    if ! [[ -s "/tmp/.lshal" ]] || ! [[ "$( wc -l "/tmp/.lshal" | cut -f 1 -d ' ' )" -gt 100 ]] ; then
        hald &
        sync
        LC_ALL=C sleep 1

        if ! timeout 20 lshal 2>/dev/null > /tmp/.lshal ; then
            timeout 30 lshal 2>/dev/null > /tmp/.lshal || true
        fi
        # save some memory
        killall hald 2>/dev/null 1>&2 || true
    fi

    # }}}

    # This is needed for the composite wizard page 150 modifications:
    if grep -qsi "system.hardware.product =.*VirtualBox" /tmp/.lshal || grep -qsi "system.hardware.product =.*vmware" /tmp/.lshal || grep "QEMU" /tmp/.lshal | egrep -q "^\s+info.vendor" ;  then
        touch "/tmp/.virtualmachine-detected" 2>/dev/null
        chmod a+rw "/tmp/.virtualmachine-detected" 2>/dev/null
    fi


    # if we are debugging give it a little pause to see what is going on
    if grep -qs "debug" /proc/cmdline ; then
        echo -e "debug: sleep 2" 1>&2
        sleep 2
    fi
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
