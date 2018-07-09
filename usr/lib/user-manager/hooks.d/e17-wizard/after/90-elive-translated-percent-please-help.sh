#!/bin/bash
source /usr/lib/elive-tools/functions
# gettext not works here because we are on first page

export GTK_THEME="Adwaita"
export GTK2_RC_FILES="/usr/share/themes/Adwaita/gtk-2.0/gtkrc"

main(){
    # pre {{{
    local lang amount percent dir total

    # }}}

    lang="${LANG%%_*}"
    if [[ -z "$lang" ]] ; then
        exit
    fi

    dir="/var/cache/elive-translations/statistics/$lang"

    if [[ -n "$LANG" ]] && [[ "$LANG" != en* ]] ; then
        if [[ -d "$dir" ]] ; then
            amount="$( ls -1 "$dir" | grep txt | wc -l )"
            total="$( echo "$( cat "$dir"/* | sed -e 's|^.*: ||g' -e 's|.*|& +|g' | tr '\n' ' ' | sed -e 's|+ $||g' )" | bc -l )"

            percent="$(( $total / $amount ))"
            # percent is the inverse (no-translated message statistics)
            percent="$(( 100 - $percent ))"

            if echo "$percent" | grep -qs "[[:digit:]]" ; then
                local message_translated
                message_translated="$( printf "$( eval_gettext "Elive is translated %s %% to your language, you can improve these translations by using the application called eltrans and it will help everybody to enjoy them." )" "$percent" )"

                if [[ "$percent" -ge 0 ]] && [[ "$percent" -le 100 ]] ; then
                    zenity --info --text="$message_translated"
                fi
            fi
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
