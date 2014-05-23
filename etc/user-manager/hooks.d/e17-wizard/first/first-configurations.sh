#!/bin/bash
source /usr/lib/elive-tools/functions

main(){
    # pre {{{
    local var

    # }}}

    # Audio configurations {{{
    el_explain 0 "Configuring audio cards..."
    audio-configurator --quiet

    el_explain 0 "Setting default volumes..."
    setvolume defaults

    # - Audio configurations }}}
    # add elive gpg key {{{

    # import gnupg keys
    el_explain 0 "Importing Elive gpg key..."

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
