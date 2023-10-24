#!/bin/sh

main(){
    # pre {{{
    #local file dir temp
    # debug mode
    # if grep -Fqs "debug" /proc/cmdline ; then
    #     export EL_DEBUG=3
    #     if grep -Fqs "completedebug" /proc/cmdline ; then
    #         set -x
    #     fi
    # fi


    if [ -e "/etc/elive/machine-profile" ] ; then
        . /etc/elive/machine-profile
    fi
    # }}}

    # This is needed for the (next) composite wizard page 150 modifications:
    if [ "$MACHINE_VIRTUAL" = "yes" ] ; then
        touch "/tmp/.virtualmachine-detected"
        chmod a+rw "/tmp/.virtualmachine-detected" 2>/dev/null
    fi
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
