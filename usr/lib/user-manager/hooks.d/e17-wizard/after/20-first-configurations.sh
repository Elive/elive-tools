#!/bin/bash
source /usr/lib/elive-tools/functions
# gettext not works here because we are on first page

main(){
    # pre {{{
    local var

    # }}}

    # Audio configurations {{{
    if ! [[ -s "$HOME/.asoundrc" ]] ; then
        rm -f "$HOME/.config/setvolume" 2>/dev/null 1>&2

        el_explain 0 "Configuring audio cards..."
        audio-configurator --quiet

    fi

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

    # if we are debugging give it a little pause to see what is going on
    if grep -qs "debug" /proc/cmdline ; then
        echo -e "debug: sleep 4" 1>&2
        sleep 4
    fi

}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
