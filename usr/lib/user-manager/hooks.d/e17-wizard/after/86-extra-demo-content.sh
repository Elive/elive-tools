#!/bin/bash
SOURCE="$0"
source /usr/lib/elive-tools/functions
EL_REPORTS="1"
el_make_environment
. gettext.sh
TEXTDOMAIN="elive-tools"
export TEXTDOMAIN



main(){
    # pre {{{
    local language

    # debug mode
    if grep -Fqs "debug" /proc/cmdline ; then
        export EL_DEBUG=3
        if grep -Fqs "completedebug" /proc/cmdline ; then
            set -x
        fi
    fi


    if ! el_dependencies_check "xdg-user-dirs-update|xdg-user-dirs-gtk-update" ; then
        exit 1
    fi
    # }}}
    source /etc/default/locale
    language="${LANG%%_*}"


    if [[ -n "$language" ]] ; then
        cd

        # download debian tutorial (mostly terminal) reference
        if el_verify_internet ; then
            if [[ "$language" = "en" ]] || curl "https://www.debian.org/doc/manuals/debian-reference/ch01.${language}.html" 2>/dev/null | grep -Fqs "Page not found" ; then
                echo -e "<meta http-equiv=\"refresh\" content=\"0;url=https://www.debian.org/doc/manuals/debian-reference/ch01.html\">" > "$( xdg-user-dir DOCUMENTS )/Basic Terminal and system Tutorial.html"
            else
                echo -e "<meta http-equiv=\"refresh\" content=\"0;url=https://www.debian.org/doc/manuals/debian-reference/ch01.${language}.html\">" > "$( xdg-user-dir DOCUMENTS )/Basic Terminal and system Tutorial.html"
            fi
        else
            echo -e "<meta http-equiv=\"refresh\" content=\"0;url=https://www.debian.org/doc/manuals/debian-reference/ch01.html\">" > "$( xdg-user-dir DOCUMENTS )/Basic Terminal and system Tutorial.html"
        fi
    fi


    if [[ -e "/tmp/.e16-reload-needed-$USER" ]] ; then
        eesh restart
        rm -f "/tmp/.e16-reload-needed-$USER"
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
