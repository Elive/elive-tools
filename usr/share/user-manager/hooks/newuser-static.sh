#!/bin/bash
source /usr/lib/elive-tools/functions

main(){
    # pre {{{
    local NUMBERRANDOM username

    # Usage
    if [[ -z "${1}" ]] ; then
        echo -e "Usage: $(basename $BASH_SOURCE) username"
        exit 1
    fi

    # checks
    if ! el_check_variables "username" ; then
        exit 1
    fi

    # variables
    if [[ -f "/etc/adduser.conf" ]] ; then
        source /etc/adduser.conf
    fi

    # input
    username="$1"


    # }}}

    # add elive gpg key {{{
    if [[ -d "/usr/share/elive-security" ]] ; then
        su -c "gpg --import /usr/share/elive-security/*.asc" "$username"
    fi

    # }}}



}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
