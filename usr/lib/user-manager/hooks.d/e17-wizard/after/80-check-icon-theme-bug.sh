#!/bin/bash
source /usr/lib/elive-tools/functions
# gettext not works here because we are on first page

main(){
    # pre {{{
    local file

    # }}}

    set -x
    if [[ -d "$HOME/.e/e17" ]] ; then
        cd "$HOME/.e/e17/config/standard"

        eet -d e.cfg config e.cfg.src

        if ! grep -qs "value \"icon_theme\" string: \"gnome\";" e.cfg.src ; then
            zenity --warning --text="$( eval_gettext "Your icons seems to be wrongly configured, press ok to restart your configuration" )"
            killall -9 enlightenment
            rm -rf "$HOME/.e" "$HOME/.xsession-errors"
        fi

        rm -f e.cfg.src
    fi
    set +x


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
