#!/bin/sh


# this runs a daemon to set the gtk theme, we can stop it in the end
gtk_set_theme(){
    if [ -s "$HOME/.xsettingsd" ] && ! pidof xsettingsd 1>/dev/null ; then
        ( xsettingsd 1>/dev/null 2>&1 & )
    fi
}

gtk_set_theme
