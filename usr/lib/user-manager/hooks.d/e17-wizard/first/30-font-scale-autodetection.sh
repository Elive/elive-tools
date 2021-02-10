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

    dpi="$( el_dpi_get "rounded" )"
    if [[ "${dpi}" = *"x"* ]] ; then
        dpi_h="${dpi%x*}"

        # temporal debug:
        if [[ "${dpi_h}" != "96" ]] && [[ "${dpi_h}" != "157" ]] ; then
            el_warning "temporal debug: new DPI found: $dpi_h"
        fi
    fi

    # generic settings:
    if [[ -n "$dpi_h" ]] ; then
        # Set scaling factor into Xdefaults
        sed -i -e '/Xft.dpi:/d' "$HOME/.Xdefaults"
        echo "Xft.dpi: $dpi_h" >> "$HOME/.Xdefaults"

        # cursor size, should be not needed because is already dynamic by dpi
        #sed -i -e '/Xcursor.size:/d' "$HOME/.Xdefaults"
        #echo "Xcursor.size: 48" >> "$HOME/.Xdefaults"

        # set a default X cursor mouse theme:
        if [[ -d "/usr/share/icons/Breeze_Snow/cursors" ]] ; then
            sed -i -e '/Xcursor.theme:/d' "$HOME/.Xdefaults"
            echo "Xcursor.theme: Breeze Snow" >> "$HOME/.Xdefaults"

        elif [[ -d "/usr/share/icons/whiteglass/cursors" ]] ; then
            sed -i -e '/Xcursor.theme:/d' "$HOME/.Xdefaults"
            echo "Xcursor.theme: whiteglass" >> "$HOME/.Xdefaults"
        fi

        scale_factor="$( echo "scale=4 ; $dpi_h / 96" | LC_ALL=C bc -l )"
        if ! echo "$scale_factor" | grep -qs "[[:digit:]]" ; then
            unset scale_factor
        fi
        #dpi_rounded="$((m=dpi_h%10, d=dpi_h-m, m >= 10/2 ? d+10 : d))"

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

        # TODO: define a scaling factor value to configure gnome-3 and elementary (which will include terminology and E too aparently)
        # TODO: VERIFY which file affects this:
        #gsettings set org.gnome.desktop.interface scaling-factor 2
        # TODO configure elementary manually?
        # TODO: terminals like urxvt (font size?)

        # TODO: create a file called ~/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml  in elive-skel files, FROM a new thunar default window opened, and change THEIR relative values to the OBTAINED ones like on this example:
#--- a/xfce4/xfconf/xfce-perchannel-xml/thunar.xml	2021-01-21 15:29:04.000000000 -0500
#+++ b/xfce4/xfconf/xfce-perchannel-xml/thunar.xml	2021-01-21 15:31:15.245482016 -0500
#@@ -3,9 +3,9 @@
 #<channel name="thunar" version="1.0">
   #<property name="last-view" type="string" value="ThunarIconView"/>
   #<property name="last-location-bar" type="string" value="ThunarLocationEntry"/>
#-  <property name="last-icon-view-zoom-level" type="string" value="THUNAR_ZOOM_LEVEL_100_PERCENT"/>
#-  <property name="last-window-width" type="int" value="1347"/>
#-  <property name="last-window-height" type="int" value="859"/>
#+  <property name="last-icon-view-zoom-level" type="string" value="THUNAR_ZOOM_LEVEL_400_PERCENT"/>
#+  <property name="last-window-width" type="int" value="1764"/>
#+  <property name="last-window-height" type="int" value="983"/>
   #<property name="last-window-maximized" type="bool" value="false"/>
#-  <property name="last-separator-position" type="int" value="315"/>
#+  <property name="last-separator-position" type="int" value="279"/>


        # TODO: set statuc average values for improved size:
            # Note: While you can set any dpi you like and applications using Qt and GTK will scale accordingly, it's recommended to set it to 96, 120 (25% higher), 144 (50% higher), 168 (75% higher), 192 (100% higher) etc., to reduce scaling artifacts to GUI that use bitmaps. Reducing it below 96 dpi may not reduce size of graphical elements of GUI as typically the lowest dpi the icons are made for is 96.


    else
        el_error "unable to get dpi value"
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

