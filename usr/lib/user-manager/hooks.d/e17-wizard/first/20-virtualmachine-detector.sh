#!/bin/sh

main(){
    # pre {{{
    #local file dir temp

    if [ -e "/etc/elive/machine-profile" ] ; then
        source /etc/elive/machine-profile
    fi
    # }}}

    # This is needed for the (next) composite wizard page 150 modifications:
    if [ "$MACHINE_VIRTUAL" = "yes" ] && [ -z "$EROOT" ] ; then
        touch "/tmp/.virtualmachine-detected"
        chmod a+rw "/tmp/.virtualmachine-detected" 2>/dev/null
    fi
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
