#!/bin/bash
source /usr/lib/elive-tools/functions

main(){
    # pre {{{
    local NUMBERRANDOM file

    # checks
    if [[ "$USER" = root ]] ; then
        exit 1
    fi

    # variables
    if [[ -z "$LANG" ]] ; then
        LANG="$(grep -s 'LANG=' /etc/default/locale | sed s/'LANG='// | tr -d '"' )"  # stupid vim syntax requires: '
    fi
    if [[ -z "$LANG" ]] ; then
        LANG="en_US.UTF-8"
    fi


    # }}}

    # set xchat random names {{{
    if ! el_check_variables "LANG,HOME" ; then
        exit 1
    fi

    if [[ -f "$HOME/.xchat2/xchat.conf" ]] ; then
        NUMBERRANDOM="$(expr $RANDOM % 100)"
        sed -i "s/irc_nick1\ =\ Elive_user/irc_nick1\ =\ Elive_user${NUMBERRANDOM}_${LANG%%_*}/" "${HOME}/.xchat2/xchat.conf"

        NUMBERRANDOM="$(expr $RANDOM % 100)"
        sed -i "s/irc_nick2\ =\ Elive_user2/irc_nick2\ =\ Elive_user${NUMBERRANDOM}_${LANG%%_*}/" "${HOME}/.xchat2/xchat.conf"

        NUMBERRANDOM="$(expr $RANDOM % 100)"
        sed -i "s/irc_nick3\ =\ Elive_user3/irc_nick3\ =\ Elive_user${NUMBERRANDOM}_${LANG%%_*}/"  "${HOME}/.xchat2/xchat.conf"
    fi


    # }}}

    # add elive gpg key {{{
    if [[ -d "/usr/share/elive-security" ]] ; then
        if el_dependencies_check gpg ; then
            gpg --import /usr/share/elive-security/*.asc
        fi
    fi

    # }}}

    # configure audio and volume for user {{{
    audio-configurator --auto
    setvolume defaults
    setvolume 90%

    # }}}

    # FIXME: we cannot run this from here, its useless, and we don't know a way to call it enough reliable
    # run hooks from packages {{{
    if [[ -d "/etc/user-manager/hooks/post-create.d" ]] ; then
        for file in /etc/user-manager/hooks/post-create.d/*
        do
            if [[ -x "$file" ]] ; then
                "$file"
            fi
        done
    fi

    # }}}


}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
