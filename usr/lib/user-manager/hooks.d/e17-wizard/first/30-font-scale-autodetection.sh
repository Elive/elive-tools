#!/bin/bash
SOURCE="$0"
source /usr/lib/elive-tools/functions
REPORTS="1"
#el_make_environment
#. gettext.sh
#TEXTDOMAIN=""
#export TEXTDOMAIN


main(){
    elive-scale-desktop --auto --quiet
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :

