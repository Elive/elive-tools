#!/bin/bash
SOURCE="$0"
source /usr/lib/elive-tools/functions
el_make_environment
. gettext.sh
TEXTDOMAIN="elive-tools"
export TEXTDOMAIN



main(){
    # pre {{{
    local language

    # }}}
    source /etc/default/locale
    language="${LANG%%_*}"


    if [[ -n "$language" ]] ; then
        cd

        # download debian tutorial (mostly terminal) reference
        if el_verify_internet ; then
            if [[ "$language" = "en" ]] || curl "https://www.debian.org/doc/manuals/debian-reference/ch01.${language}.html" 2>/dev/null | grep -qs "Page not found" ; then
                echo -e "<meta http-equiv=\"refresh\" content=\"0;url=https://www.debian.org/doc/manuals/debian-reference/ch01.html\">" > "$( xdg-user-dir DOCUMENTS )/Basic Terminal and system Tutorial.html"
            else
                echo -e "<meta http-equiv=\"refresh\" content=\"0;url=https://www.debian.org/doc/manuals/debian-reference/ch01.${language}.html\">" > "$( xdg-user-dir DOCUMENTS )/Basic Terminal and system Tutorial.html"
            fi
        else
            echo -e "<meta http-equiv=\"refresh\" content=\"0;url=https://www.debian.org/doc/manuals/debian-reference/ch01.html\">" > "$( xdg-user-dir DOCUMENTS )/Basic Terminal and system Tutorial.html"
        fi
    fi

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
