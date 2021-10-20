#!/bin/bash
SOURCE="$0"
source /usr/lib/elive-tools/functions
EL_REPORTS="1"
. gettext.sh
TEXTDOMAIN="elive-tools"
export TEXTDOMAIN




main(){
    # pre {{{
    #local file

    # }}}

    # e16
    if [[ -n "$EROOT" ]] ; then
        # nothing to do
        return 0
    fi

    # e17
    if [[ -d "$HOME/.e/e17" ]] ; then
        cd "$HOME/.e/e17/config/standard"

        if [[ -x "$(which eet)" ]] ; then
            eet -d e.cfg config e.cfg.src

            if ! grep -qs "value \"icon_theme\" string: \"gnome\";" e.cfg.src && [[ -s "/usr/share/icons/gnome/index.theme" ]] ; then
                zenity --warning --text="$( eval_gettext "Your icons seems to be wrongly configured, press ok to restart your configuration" )"
                e17-restart-and-remove-conf-file-WARNING-dont-complain
            fi

            rm -f e.cfg.src
        else
            el_warning "eet command not found"
        fi
    fi


    # if we are debugging give it a little pause to see what is going on
    #if grep -qs "debug" /proc/cmdline ; then
        #echo -e "debug: sleep 4" 1>&2
        #sleep 4
    #fi

}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
