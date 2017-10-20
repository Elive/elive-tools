#!/bin/bash
main(){
    # pre {{{
    local resolution font

    # }}}


    # get the optimal font name
    if enlightenment_remote -font-list | grep -qs "DejaVu Sans:" ; then
        font="DejaVu Sans"
    else
        font="Sans"
    fi

    # automatically set the Font for applications in an optimal size based in the DPI:
    enlightenment_remote -font-set-auto "application" "$font"


    resolution="$( enlightenment_remote -resolution-get | sed -e 's|x.*$||g' )"
    read -r resolution <<< "$resolution"

    # set more specific font sizes for extreme cases
    if [[ "$resolution" -gt 1024 ]] ; then
        # not needed: we have it already set more optimally
        #enlightenment_remote -font-set "application" "$font" 9
        true
    else
        if [[ "$resolution" -ge 800 ]] ; then
            # resolutions between 800x* & 1024x*
            enlightenment_remote -font-set "application" "$font" 8
            # urxvt font size:
            sed -i -e 's|\(^URxvt.font.*:pixelsize\)=.*|\1=9|g' "$HOME/.Xdefaults"
            xrdb -merge "$HOME/.Xdefaults"
        else
            if [[ "$resolution" -lt 800 ]] ; then
                # very extreme cases (very small screens)
                enlightenment_remote -font-set "application" "$font" 7
                # urxvt font size:
                sed -i -e 's|\(^URxvt.font.*:pixelsize\)=.*|\1=9|g' "$HOME/.Xdefaults"
                xrdb -merge "$HOME/.Xdefaults"
            fi
        fi
    fi

    enlightenment_remote -save


    # if we are debugging give it a little pause to see what is going on
    if grep -qs "debug" /proc/cmdline ; then
        echo -e "debug: sleep 2" 1>&2
    fi
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :

