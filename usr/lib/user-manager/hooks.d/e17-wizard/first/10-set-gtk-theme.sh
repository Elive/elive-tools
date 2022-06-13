#!/bin/sh

# set a specific wallpaper for the actual release if there's any
e16_set_release_wallpaper(){
    if [ -n "$EROOT" ] && [ -d /etc/elive/wallpaper ] ; then
        wallpaper="$( find /etc/elive/wallpaper/ -type f \( -iname '*'jpg -o -iname '*'jpeg -o -iname '*'png \) | tail -1 )"
        if [ -s "$wallpaper" ] ; then
            name="$( echo "$wallpaper" | sed -e 's|^.*/||g' -e 's|\.*$||g' )"
            eesh bg xset "$name" 0 0 0 "$wallpaper" 0 0 0 0 1024 1024 "" 0 0 0 0 0
            if eesh bg list | grep -qs "^${name}$" ; then
                eesh bg use "$name" 0
                eesh bg use "$name" 1
            else
                el_warning "bg not correctly configured?\n$(eesh bg list)"
            fi
        else
            el_warning "/etc/elive/wallpaper has not a correct bg? \n$( ls -1 /etc/elive/wallpaper/ )"
        fi
    fi
}

# this runs a daemon to set the gtk theme, we can stop it in the end
gtk_set_theme(){
    if [ -s "$HOME/.xsettingsd" ] && ! pidof xsettingsd 1>/dev/null ; then
        ( xsettingsd 1>/dev/null 2>&1 & )
    fi
}

e16_set_release_wallpaper
gtk_set_theme
