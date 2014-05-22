#!/bin/bash
source /usr/lib/elive-tools/functions

main(){
    # pre {{{
    local var

    # }}}

    # import gnupg keys
    el_explain 0 "Importing Elive gpg key..."

    if [[ -d "/usr/share/elive-security" ]] ; then
        gpg --import /usr/share/elive-security/*.asc
    fi


}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
