#!/bin/bash
SOURCE="$0"
source /usr/lib/elive-tools/functions
EL_REPORTS="1"
. gettext.sh
TEXTDOMAIN="elive-tools"
export TEXTDOMAIN


fix_cairodock(){
    if [[ "$( pidof cairo-dock | wc -w )" -ge 2 ]] ; then
        killall cairo-dock 1>/dev/null 2>&1
        killall -9 cairo-dock 1>/dev/null 2>&1
        bash -c "cairo-dock  & disown"
    fi
}


main(){
    # pre {{{
    #local file

    # debug mode
    if grep -Fqs "debug" /proc/cmdline ; then
        export EL_DEBUG=3
        if grep -Fqs "completedebug" /proc/cmdline ; then
            set -x
        fi
    fi

    # }}}

    # e16
    if [[ -n "$EROOT" ]] ; then
        fix_cairodock
        # nothing to do
        return 0
    fi

    # e17
    if [[ -d "$HOME/.e/e17" ]] ; then
        cd "$HOME/.e/e17/config/standard"

        if [[ -x "$(which eet)" ]] ; then
            eet -d e.cfg config e.cfg.src

            if ! grep -qs "value \"icon_theme\" string: \"gnome\";" e.cfg.src && [[ -s "/usr/share/icons/gnome/index.theme" ]] ; then
                zenity --warning --text="$( eval_gettext "Your desktop has not been correctly configured. So we will try again." )"
                e17-restart-and-remove-conf-file-WARNING-dont-complain
            fi

            rm -f e.cfg.src
        else
            el_warning "eet command not found"
        fi
    fi

    # e26
    if [[ "$E_HOME_DIR" = *"/.e/e" ]] ; then
        if [[ -e "/tmp/.${USER}-e-wizard-finished.stamp" ]] ; then
            rm -f "/tmp/.${USER}-e-wizard-finished.stamp"
        else
            zenity --warning --text="$( eval_gettext "Your desktop has not been correctly configured. So we will try again." )"
            e17-restart-and-remove-conf-file-WARNING-dont-complain
        fi
    fi

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
