#!/bin/bash
source /usr/lib/elive-tools/functions

main(){
    # pre {{{
    local NUMBERRANDOM

    # checks
    if [[ "$USER" = root ]] ; then
        exit 1
    fi


    # }}}

    # add elive gpg key {{{
    if [[ -d "/usr/share/elive-security" ]] ; then
        if el_dependencies_check gpg ; then
            gpg --import /usr/share/elive-security/*.asc
        fi
    fi

    # }}}



}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
