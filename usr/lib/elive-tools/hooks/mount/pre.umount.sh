#!/bin/bash
#source /usr/lib/elive-tools/functions

main(){
    # pre {{{
    local filesystem mountpoint partition label

    label="$1"
    partition="$2"
    mountpoint="$3"
    filesystem="$4"

    # }}}

    # kill sucky process that doesn't allow us to umount devices
    #if top -b -n 1 | head -n 14 | tail -n 7  | grep -q tumblerd 2>/dev/null 1>/dev/null ; then
        killall tumblerd 2>/dev/null 1>/dev/null
        killall -9 tumblerd 2>/dev/null 1>/dev/null
    #fi

    # make sure that previous commands has perfectly finished, and:
    # make sure that all the syncs are finished before to try to umount, to avoid errors umounting (in buster too)
    sync

    exit 0
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
