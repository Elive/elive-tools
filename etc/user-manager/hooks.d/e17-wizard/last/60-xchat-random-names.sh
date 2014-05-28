#!/bin/bash
source /usr/lib/elive-tools/functions


main(){
    # pre {{{
    local ip number md5ip NUMBERRANDOM

    # }}}

    # set xchat random names {{{
    # checks {{{
    if ! el_check_variables "HOME" || ! [[ -d "$HOME" ]]  ; then
        el_error "no HOME exist for this user? exiting..."
        sleep 2
        exit 1
    fi

    if el_check_variables "LANG" ; then
        if ! echo "$LANG" | grep -qsi "UTF" ; then
            el_warning "Your language is not set to UTF-8 mode? '$LANG'"
        fi
    else
        el_warning "LANG variable is not set?"
    fi

    # - checks }}}

    if [[ -f "$HOME/.xchat2/xchat.conf" ]] ; then
        ip="$( showmyip )"

        if [[ -n "$ip" ]] ; then
            md5ip="$( echo "$ip" | md5sum | awk '{print $1}' )"

            NUMBERRANDOM="${md5ip:0:2}"
            sed -i "s|irc_nick1 = Elive_user1|irc_nick1 = Elive_user_${LANG%%_*}_${NUMBERRANDOM}|" "${HOME}/.xchat2/xchat.conf" || true

            NUMBERRANDOM="${md5ip:2:2}"
            sed -i "s|irc_nick2 = Elive_user2|irc_nick2 = Elive_user_${LANG%%_*}_${NUMBERRANDOM}|" "${HOME}/.xchat2/xchat.conf" || true

            NUMBERRANDOM="${md5ip:4:2}"
            sed -i "s|irc_nick3 = Elive_user3|irc_nick3 = Elive_user_${LANG%%_*}_${NUMBERRANDOM}|" "${HOME}/.xchat2/xchat.conf" || true
        else

            randomized="$RANDOM$RANDOM$RANDOM"

            NUMBERRANDOM="${randomized:0:2}"
            sed -i "s|irc_nick1 = Elive_user1|irc_nick1 = Elive_user_${LANG%%_*}_${NUMBERRANDOM}|" "${HOME}/.xchat2/xchat.conf" || true

            NUMBERRANDOM="${randomized:2:2}"
            sed -i "s|irc_nick2 = Elive_user2|irc_nick2 = Elive_user_${LANG%%_*}_${NUMBERRANDOM}|" "${HOME}/.xchat2/xchat.conf" || true

            NUMBERRANDOM="${randomized:4:2}"
            sed -i "s|irc_nick3 = Elive_user3|irc_nick3 = Elive_user_${LANG%%_*}_${NUMBERRANDOM}|" "${HOME}/.xchat2/xchat.conf" || true
        fi
    else
        el_error "No xchat conf dir exist? ignoring..."
    fi


    # }}}

}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
