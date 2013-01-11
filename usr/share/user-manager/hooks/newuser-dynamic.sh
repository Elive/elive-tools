#!/bin/bash
source /usr/lib/elive-tools/functions

main(){
    # pre {{{
    local NUMBERRANDOM

    # checks
    if [[ "$USER" = root ]] ; then
        exit 1
    fi

    # variables
    if [[ -z "$LANG" ]] ; then
        LANG="$(grep -s 'LANG=' /etc/default/locale | sed s/'LANG='// | tr -d '"' )"  # stupid syntax requires: '
    fi


    # }}}

    # set xchat random names {{{
    if ! el_check_variables "LANG,HOME" ; then
        exit 1
    fi

    if [[ -f "$HOME/.xchat2/xchat.conf" ]] ; then
        NUMBERRANDOM="$(expr $RANDOM % 100)"
        sed -i "s/irc_nick1\ =\ Elive_user/irc_nick1\ =\ Elive_user${NUMBERRANDOM}_${LANG:0:2}/" "${HOME}/.xchat2/xchat.conf"

        NUMBERRANDOM="$(expr $RANDOM % 100)"
        sed -i "s/irc_nick2\ =\ Elive_user2/irc_nick2\ =\ Elive_user${NUMBERRANDOM}_${LANG:0:2}/" "${HOME}/.xchat2/xchat.conf"

        NUMBERRANDOM="$(expr $RANDOM % 100)"
        sed -i "s/irc_nick3\ =\ Elive_user3/irc_nick3\ =\ Elive_user${NUMBERRANDOM}_${LANG:0:2}/"  "${HOME}/.xchat2/xchat.conf"
    fi


    # }}}


}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
