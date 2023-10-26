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
    if [ -n "$EROOT" ] && [ -d /etc/elive/wallpaper ] ; then
        wallpaper="$( find /etc/elive/wallpaper/ -type f \( -iname '*'jpg -o -iname '*'jpeg -o -iname '*'png \) | tail -1 )"

        if [ -s "$wallpaper" ] ; then
            ( elive-wallpaper-set "$wallpaper" & )
        else
            if ! grep -Fqs "special-version: yes" /etc/elive-version ; then
                el_warning "/etc/elive/wallpaper has not a correct bg? \n$( ls -1 /etc/elive/wallpaper/ )"
            fi
        fi
    fi
}

# this runs a daemon to set the gtk theme, we can stop it in the end
gtk_set_theme(){
    if [ -s "$HOME/.xsettingsd" ] && ! pidof xsettingsd 1>/dev/null ; then
        ( xsettingsd 1>/dev/null 2>&1 & )
    fi
}

verify_x11_access
e16_set_release_wallpaper
gtk_set_theme
