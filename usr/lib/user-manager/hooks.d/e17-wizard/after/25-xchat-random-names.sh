#!/bin/bash
SOURCE="$0"
source /usr/lib/elive-tools/functions
EL_REPORTS="1"


main(){
    # pre {{{
    local ip number md5ip NUMBERRANDOM

    if grep -Fqs "boot=live" /proc/cmdline ; then
        is_live=1
    fi

    # debug mode
    if grep -Fqs "debug" /proc/cmdline ; then
        export EL_DEBUG=3
        if grep -Fqs "completedebug" /proc/cmdline ; then
            set -x
        fi
    fi


    # }}}

    # set hexchat random names {{{
    # checks {{{
    if ! el_check_variables "HOME" || ! [[ -d "$HOME" ]]  ; then
        el_error "no HOME exist for this user? exiting..."
        sleep 2
        exit 1
    fi

    if [[ -z "$LANG" ]] ; then
        el_warning "LANG variable is not set?"
    fi


    # - checks }}}

    if [[ -f "$HOME/.config/hexchat/hexchat.conf" ]] ; then

        randomized="$RANDOM$RANDOM$RANDOM"

        NUMBERRANDOM="${randomized:0:2}"
        sed -i "s|^.*irc_nick1 = Elive.*1.*$|irc_nick1 = EliveLinux_${LANG%%_*}_${NUMBERRANDOM}|" "${HOME}/.config/hexchat/hexchat.conf" || true
        if ((is_live)) ; then
            sudo -H sed -i "s|^.*irc_nick1 = Elive.*1.*$|irc_nick1 = EliveLinux_${LANG%%_*}_${NUMBERRANDOM}|" "/etc/skel/.config/hexchat/hexchat.conf" || true
        fi

        NUMBERRANDOM="${randomized:2:2}"
        sed -i "s|^.*irc_nick2 = Elive.*2.*$|irc_nick2 = EliveLinux_${LANG%%_*}_${NUMBERRANDOM}|" "${HOME}/.config/hexchat/hexchat.conf" || true
        if ((is_live)) ; then
            sudo -H sed -i "s|^.*irc_nick2 = Elive.*2.*$|irc_nick2 = EliveLinux_${LANG%%_*}_${NUMBERRANDOM}|" "/etc/skel/.config/hexchat/hexchat.conf" || true
        fi

        NUMBERRANDOM="${randomized:4:2}"
        sed -i "s|^.*irc_nick3 = Elive.*3.*$|irc_nick3 = EliveLinux_${LANG%%_*}_${NUMBERRANDOM}|" "${HOME}/.config/hexchat/hexchat.conf" || true
        if ((is_live)) ; then
            sudo -H sed -i "s|^.*irc_nick3 = Elive.*3.*$|irc_nick3 = EliveLinux_${LANG%%_*}_${NUMBERRANDOM}|" "/etc/skel/.config/hexchat/hexchat.conf" || true
        fi
    fi


    # }}}

    # if we are debugging give it a little pause to see what is going on
    #if grep -Fqs "debug" /proc/cmdline ; then
        #echo -e "debug: sleep 4" 1>&2
        #sleep 4
    #fi

}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
