#!/bin/bash
#SOURCE="$0"
source /usr/lib/elive-tools/functions
#REPORTS="1"
#el_make_environment
#. gettext.sh
#TEXTDOMAIN=""
#export TEXTDOMAIN

ERM(){
    if [[ -n "$E_START" ]] ; then
        el_warning "disabled eremote for fonts configurations in the new versions: $@"
        #enlightenment_remote "$@"
        true
        return "$?"
    fi
    if [[ -n "$EROOT" ]] ; then
        # ignore ERM, not needed (eesh)
        true
        return "$?"
    fi
}

# INFO:
# Default sizes for the differents dpi's:
# - 96x96:  8
font_size_change(){
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

    # urxvt size:
    # should be statically set to 10 ?? i think it doesn't change
    #sed -i -e "s|pixelsize=.*$|pixelsize=$(( $size + 2 ))|g" "$HOME/.Xdefaults"

    # conky font size change?
    #sed -i -e 's|:size=8|:size=7|g' "$HOME/.conkyrc"


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

    # defaults
    resolution="$( el_resolution_get )"
    resolution_h="${resolution%%x*}"
    resolution_v="${resolution##*x}"
    font="DejaVu Sans"

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

        #resolution="$( enlightenment_remote -resolution-get )"
        #read -r resolution <<< "$resolution"
        #resolution_h="${resolution%%x*}"
        #resolution_v="${resolution##*x}"
    fi


    # this should be the default for all dpi's with the new scaling system:
    #font_size_change "8"
    # el_dpi_get in mode lowered en 157
    #font_size_change "9"
    # el_dpi_get in mode lowered en 96
    font_size_change "8"

    # set more specific font sizes for extreme cases
    if [[ "$resolution_h" -le 1024 ]] ; then
        # disable google chrome bookmarks due to size limitations (only in live due to sudo)
        for i in "$HOME/.config/google-chrome/Default/Preferences" "$HOME/.config/chromium/Default/Preferences" "/etc/chromium/master_preferences" "/etc/google-chrome/master_preferences" "/etc/skel/.config/google-chrome/Default/Preferences" "/etc/skel/.config/chromium/Default/Preferences"
        do
            if grep -qs "boot=live" /proc/cmdline ; then
                sudo -H sed -i -e "s|^.*\"show_on_all_tabs\":.*$|\"show_on_all_tabs\":false|g" "$i"
                sudo -H sed -i -e "s|^.*\"show_on_all_tabs\" :.*$|\"show_on_all_tabs\" : false|g" "$i"
            else
                sed -i -e "s|^.*\"show_on_all_tabs\":.*$|\"show_on_all_tabs\":false|g" "$i" 2>/dev/null || true
                sed -i -e "s|^.*\"show_on_all_tabs\" :.*$|\"show_on_all_tabs\" : false|g" "$i" 2>/dev/null || true
            fi
        done
    fi

    #if [[ "$resolution_h" -ge 800 ]] ; then
        ## resolutions between 800x* & 1024x*
        #ERM -font-set "application" "$font" 8
        #font_size_change "8"
    #fi
    if [[ "$resolution_h" -le 800 ]] ; then
        # very extreme cases (very small screens)
        ERM -font-set "application" "$font" 7
        font_size_change "7"
        # conky small screens configurations:
        sed -i -e 's|:size=8|:size=7|g' "$HOME/.conkyrc"
        sed -i -e '/^$/d' "$HOME/.conkyrc"
    fi

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

