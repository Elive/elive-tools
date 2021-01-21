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

    dpi="$( el_dpi_get )"
    if [[ "${dpi}" = *"x"* ]] ; then
        dpi_h="${dpi%x*}"

        # temporal debug:
        if [[ "${dpi_h}" != "96" ]] ; then
            el_warning "temporal debug: new DPI found: $dpi_h"
        fi
    fi

    # generic settings:
    if [[ -n "$dpi_h" ]] ; then
        # Set scaling factor into Xdefaults
        sed -i -e '/Xft.dpi:/d' "$HOME/.Xdefaults"
        echo "Xft.dpi: $dpi_h" >> "$HOME/.Xdefaults"

        scale_factor="$( echo "scale=4 ; $dpi_h / 96" | LC_ALL=C bc -l )"
        if ! echo "$scale_factor" | grep -qs "[[:digit:]]" ; then
            unset scale_factor
        fi
        #dpi_rounded="$((m=dpi_h%10, d=dpi_h-m, m >= 10/2 ? d+10 : d))"

        if [[ -n "$scale_factor" ]] ; then
            # set gsettings (saved in ~/.config/dconf/user )
            # update: not works with dots (?)
            #gsettings set org.gnome.desktop.interface scaling-factor "${scale_factor}"

            # set elementary and all E to use the same scaling: NOTE: it is not working ATM
            #elementary_config -q -s "${scale_factor}"

            # set urxvt to a specific size
            # FIXME: this is overwritten after aparently
            rxvt_font_size="$( echo "9 * ${scale_factor}" | bc -l | sed -e 's|\..*$||g' )"
            sed -i -e "s|pixelsize=.*$|pixelsize=${rxvt_font_size}|g" "$HOME/.Xdefaults"
        fi

        # TODO: define a scaling factor value to configure gnome-3 and elementary (which will include terminology and E too aparently)
        # TODO: VERIFY which file affects this:
        #gsettings set org.gnome.desktop.interface scaling-factor 2
        # TODO configure elementary manually?
        # TODO: terminals like urxvt (font size?)

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

