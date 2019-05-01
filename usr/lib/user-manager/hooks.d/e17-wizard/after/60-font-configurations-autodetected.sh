#!/bin/bash
ERM(){
    if [[ -n "$E_START" ]] ; then
        enlightenment_remote "$@"
        return "$?"
    fi
    if [[ -n "$EROOT" ]] ; then
        # ignore ERM, not needed (eesh)
        true
        return "$?"
    fi

    el_warning "enlightenment_remote not available?"
}

main(){
    # pre {{{
    local resolution font

    # }}}


    # e16
    if [[ -n "$EROOT" ]] ; then
        true
        resolution="$( LC_ALL=C xrandr -q | grep "^Screen 0" | tr ',' '\n' | grep "current .*x" | sed -e 's|^.*current ||g' -e 's| ||g' -e 's|x.*$||g' | head -1 )"
        read -r resolution <<< "$resolution"
        # defaults
        font="DejaVu Sans"
    fi

    # e17
    if [[ -n "$E_START" ]] ; then
        # check
        if [[ "$(enlightenment_remote -ping)" != *pong ]] ; then
            el_error "Unable to connect to DBUS enlightenment_remote"
            exit 1
        fi

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
    fi



    # set more specific font sizes for extreme cases
    if [[ "$resolution" -gt 1024 ]] ; then
        # not needed: we have it already set more optimally
        #ERM -font-set "application" "$font" 9
        true
    else
        # disable google chrome bookmarks due to size limitations
        sed -i -e "s|\"show_on_all_tabs\":true|\"show_on_all_tabs\":false|g" "$HOME/.config/google-chrome/Default/Preferences"
        sed -i -e "s|\"show_on_all_tabs\" : true|\"show_on_all_tabs\" : false|g" "$HOME/.config/google-chrome/Default/Preferences"

        if [[ "$resolution" -ge 800 ]] ; then
            # resolutions between 800x* & 1024x*
            ERM -font-set "application" "$font" 8
            # urxvt font size:
            sed -i -e 's|\(^URxvt.font.*:pixelsize\)=.*|\1=9|g' "$HOME/.Xdefaults"
            xrdb "$HOME/.Xdefaults"
        else
            if [[ "$resolution" -lt 800 ]] ; then
                # very extreme cases (very small screens)
                ERM -font-set "application" "$font" 7
                # urxvt font size:
                sed -i -e 's|\(^URxvt.font.*:pixelsize\)=.*|\1=9|g' "$HOME/.Xdefaults"
                xrdb "$HOME/.Xdefaults"
            fi
        fi
    fi

    # TODO: add terminology support (12 default, 10 for medium-small, since buster)

    # save confs
    ERM -save


    # if we are debugging give it a little pause to see what is going on
    #if grep -qs "debug" /proc/cmdline ; then
        #echo -e "debug: sleep 2" 1>&2
    #fi
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :

