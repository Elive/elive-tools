#!/bin/bash
#SOURCE="$0"
source /usr/lib/elive-tools/functions
#REPORTS="1"
#el_make_environment
#. gettext.sh
#TEXTDOMAIN=""
#export TEXTDOMAIN


main(){
    # debug mode
    if grep -Fqs "debug" /proc/cmdline ; then
        export EL_DEBUG=3
        if grep -Fqs "completedebug" /proc/cmdline ; then
            set -x
        fi
    fi

    elive-scale-desktop --auto --quiet
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :

