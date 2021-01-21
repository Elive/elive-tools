#!/bin/bash
#SOURCE="$0"
#source /usr/lib/elive-tools/functions
#REPORTS="1"
#el_make_environment
#. gettext.sh
#TEXTDOMAIN=""
#export TEXTDOMAIN


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

gtk_font_size_change(){
    # XXX not needed if we use scaling
    local size is_xsettingsd_running
    size="$1"

    if pidof xsettingsd 1>/dev/null 2>&1 ; then
        is_xsettingsd_running=1
        killall xsettingsd
    fi

    # xsettingsd confs:
    sed -i -e "/FontName /s|Sans.*$|Sans $size\"|g" "$HOME/.xsettingsd"
    # gtk-3
    sed -i -e "/^gtk-font-name=/s|Sans.*$|Sans $size|g" "$HOME/.config/gtk-3.0/settings.ini"
    # gtk-2
    sed -i -e "/^gtk-font-name=/s|Sans.*$|Sans $size\"|g" "$HOME/.gtkrc-2.0"


    # load settings
    xrdb -merge "$HOME/.Xdefaults"

    if ((is_xsettingsd_running)) ; then
        ( xsettingsd 1>/dev/null 2>&1 & )
    fi
}

main(){
    # pre {{{
    local resolution resolution_v resolution_h font

    # }}}

    # e16
    if [[ -n "$EROOT" ]] ; then
        resolution="$( el_resolution_get )"
        resolution_h="${resolution%%x*}"
        resolution_v="${resolution##*x}"
        # defaults
        font="DejaVu Sans"
    fi

    # e17
    if [[ -n "$E_START" ]] ; then
        # check
        if [[ "$( enlightenment_remote -ping )" != *pong ]] ; then
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

        resolution="$( enlightenment_remote -resolution-get )"
        read -r resolution <<< "$resolution"
        resolution_h="${resolution%%x*}"
        resolution_v="${resolution##*x}"
    fi



    # set more specific font sizes for extreme cases
    if [[ "$resolution_h" -gt 1024 ]] ; then
        # not needed: we have it already set more optimally
        #ERM -font-set "application" "$font" 9
        #gtk_font_size_change "10"
        true
    else
        # disable google chrome bookmarks due to size limitations
        for i in "$HOME/.config/google-chrome/Default/Preferences" "$HOME/.config/chromium/Default/Preferences" "/etc/chromium/master_preferences" "/etc/google-chrome/master_preferences" "/etc/skel/.config/google-chrome/Default/Preferences" "/etc/skel/.config/chromium/Default/Preferences"
        do
            sed -i -e "s|^.*\"show_on_all_tabs\":.*$|\"show_on_all_tabs\":false|g" "$i"
            sed -i -e "s|^.*\"show_on_all_tabs\" :.*$|\"show_on_all_tabs\" : false|g" "$i"
        done

        if [[ "$resolution_h" -ge 800 ]] ; then
            # resolutions between 800x* & 1024x*
            ERM -font-set "application" "$font" 8
            gtk_font_size_change "8"
            # urxvt font size:
            #sed -i -e 's|\(^URxvt.font.*:pixelsize\)=.*|\1=9|g' "$HOME/.Xdefaults"
            sed -i -e 's|pixelsize=.*$|pixelsize=9|g' "$HOME/.Xdefaults"
        else
            if [[ "$resolution_h" -lt 800 ]] ; then
                # very extreme cases (very small screens)
                ERM -font-set "application" "$font" 7
                gtk_font_size_change "7"
                # urxvt font size:
                sed -i -e 's|pixelsize=.*$|pixelsize=7|g' "$HOME/.Xdefaults"
            fi
        fi
    fi

    if [[ "$resolution_v" -le 800 ]] ; then
        sed -i -e 's|:size=8|:size=7|g' "$HOME/.conkyrc"
        sed -i -e '/^$/d' "$HOME/.conkyrc"
    fi

    # TODO: add terminology support (12 default, 10 for medium-small, since buster)

    # save confs
    if [[ -n "$E_START" ]] ; then
        ERM -save
    fi

    # load settings
    xrdb -merge "$HOME/.Xdefaults"

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

