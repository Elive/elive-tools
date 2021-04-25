#!/bin/bash
SOURCE="$0"
source /usr/lib/elive-tools/functions
REPORTS="1"
#el_make_environment
#. gettext.sh
#TEXTDOMAIN=""
#export TEXTDOMAIN


main(){
    # pre {{{

    # }}}

    # fetch machine dpi
    dpi="$( el_dpi_get "lowered" )"
    # premature exit
    if [[ "${dpi}" != *"x"* ]] ; then
        el_error "unable to get machine DPI: $( el_dpi_get 'lowered' 2>&1)"
        return 0
    fi

    # if was not configured yet
    if ! grep -qs "^Xft.dpi: [[:digit:]]" "$HOME/.Xdefaults" ; then
        # Set scaling factor into Xdefaults
        sed -i -e '/Xft.dpi:/d' "$HOME/.Xdefaults"
        echo "Xft.dpi: ${dpi%x*}" >> "$HOME/.Xdefaults"
        is_restart_needed=1
    fi

    # cursor size, should be not needed because is already dynamic by dpi
    #sed -i -e '/Xcursor.size:/d' "$HOME/.Xdefaults"
    #echo "Xcursor.size: 48" >> "$HOME/.Xdefaults"

    # DEFAULT cursor theme forced:
    if ! grep -qs "^Xcursor.theme: Breeze_Snow" "$HOME/.Xdefaults" ; then
        if [[ -d "/usr/share/icons/Breeze_Snow/cursors" ]] ; then
            sed -i -e '/Xcursor.theme:/d' "$HOME/.Xdefaults"
            echo "Xcursor.theme: Breeze_Snow" >> "$HOME/.Xdefaults"
            is_restart_needed=1
        fi
    fi

    # if we don't have any cursor theme set:
    if ! grep -qs "^Xcursor.theme: " "$HOME/.Xdefaults" ; then
        if [[ -d "/usr/share/icons/whiteglass/cursors" ]] ; then
            sed -i -e '/Xcursor.theme:/d' "$HOME/.Xdefaults"
            echo "Xcursor.theme: whiteglass" >> "$HOME/.Xdefaults"
            is_restart_needed=1
        fi
    fi

    # set default scale factor value for specific apps and confs
    scale_factor="$( echo "scale=4 ; ${dpi%x*} / 96" | LC_ALL=C bc -l )"
    if ! echo "$scale_factor" | grep -qs "[[:digit:]]" ; then
        unset scale_factor
    fi

    if [[ -n "$scale_factor" ]] ; then
        # set gsettings (saved in ~/.config/dconf/user )
        # update: not works with dots (?)
        #gsettings set org.gnome.desktop.interface scaling-factor "${scale_factor}"

        # set elementary and all E to use the same scaling:
        elementary_config -q -s "${scale_factor}"

        # set urxvt to a specific size
        # FIXME: this is overwritten after aparently
        rxvt_font_size="$( echo "9 * ${scale_factor}" | bc -l | sed -e 's|\..*$||g' )"
        sed -i -e "s|pixelsize=.*$|pixelsize=${rxvt_font_size}|g" "$HOME/.Xdefaults"

        # cairo-dock size, 34 value is the default size we used to have
        cairo_dock_icon_size="$( echo "34 * ${scale_factor}" | bc -l | sed -e 's|\..*$||g' )"
        sed -i -e "s|^launcher size=.*$|launcher size=${cairo_dock_icon_size};${cairo_dock_icon_size};|g" "$HOME/.config/cairo-dock/current_theme/cairo-dock.conf"
        cairo_dock_zoom_space="$( echo "175 * ${scale_factor}" | bc -l | sed -e 's|\..*$||g' )"
        sed -i -e "s|^sinusoid width=.*$|sinusoid width=${cairo_dock_zoom_space}|g" "$HOME/.config/cairo-dock/current_theme/cairo-dock.conf"

        # thunar sizes:
        thunar_separator_position="$( echo "180 * ${scale_factor}" | bc -l | sed -e 's|\..*$||g' )"
        thunar_window_width="$( echo "640 * ${scale_factor}" | bc -l | sed -e 's|\..*$||g' )"
        thunar_window_height="$( echo "490 * ${scale_factor}" | bc -l | sed -e 's|\..*$||g' )"
        sed -i -e "/last-separator-position/s/value=\".*\"/value=\"${thunar_separator_position}\"/g" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml"
        sed -i -e "/last-window-width/s/value=\".*\"/value=\"${thunar_window_width}\"/g" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml"
        sed -i -e "/last-window-height/s/value=\".*\"/value=\"${thunar_window_height}\"/g" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml"
    fi


    # load settings
    xrdb -merge "$HOME/.Xdefaults"

    # reload desktop
    if ((is_restart_needed)) ; then
        if [[ -n "$EROOT" ]] ; then
            eesh save_config
            eesh restart
        fi
    fi

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

