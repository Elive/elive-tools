#!/bin/bash
source /usr/lib/elive-tools/functions

# debug mode
if grep -Fqs "debug" /proc/cmdline ; then
    export EL_DEBUG=3
    if grep -Fqs "completedebug" /proc/cmdline ; then
        set -x
    fi
fi


# make sure we have access to X11 or otherwise fail
verify_x11_access(){
    if ! xrdb -merge "$HOME/.Xdefaults" ; then
        echo -e "E: unable to access to X11 DISPLAY '$DISPLAY', exiting from X..."
        #if [ -n "$EROOT" ] ; then
            #eesh logout
        #else
            #if [ -n "$E_START" ] ; then
                #enlightenment_remote -logout
            #fi
        #fi
        # update: since we don't have access to X11, we cannot logout, so let's just break entirely the desktop and configure a new one (we are already on this step so we lose nothing)
        e17-restart-and-remove-conf-file-WARNING-dont-complain
    fi
}

# set a specific wallpaper for the actual release if there's any
e16_set_release_wallpaper(){
    # if we have a wallpaper to set
    if [ -d /etc/elive/wallpaper ] ; then
        # only for non-special versions like retrowave, they include already a good wallpaper in the theme:
        if ! [ -e /var/lib/dpkg/info/elive-skel-retrowave-all.list ] ; then
            wallpaper="$( find /etc/elive/wallpaper/ -type f \( -iname '*'jpg -o -iname '*'jpeg -o -iname '*'png \) | tail -1 )"

            if [ -s "$wallpaper" ] ; then
                if [ -n "$EROOT" ] ; then
                    ( elive-wallpaper-set "$wallpaper" & )
                fi
            else
                if ! grep -Fqs "special-version: yes" /etc/elive-version ; then
                    el_warning "/etc/elive/wallpaper has not a correct bg? \n$( ls -1 /etc/elive/wallpaper/ )"
                fi
            fi
        fi
    fi
}

# this runs a daemon to set the gtk theme, we can stop it in the end
gtk_set_theme(){
    if [ -n "$EROOT" ] && [ -s "$HOME/.xsettingsd" ] && ! pidof xsettingsd 1>/dev/null ; then
        ( xsettingsd 1>/dev/null 2>&1 & )
    fi
}

elm_set_theme(){
    # set elementary theme light to match "elive light" theme and have a better default
    if [ -n "$EROOT" ] ; then
        elementary_config -q -p light
    else
        # not needed since we set it later in 12-ethemes.sh
        true
    fi
}

verify_x11_access
e16_set_release_wallpaper
gtk_set_theme
elm_set_theme
