#!/bin/bash
main(){
    # pre {{{
    local resolution font

    # }}}

    # disable XV rendering if we cannot use it
    if xvinfo | grep -qs "screen #" && xvinfo | grep -qs "no adaptors present" ; then
        touch "$HOME/.mplayer/gui.conf" "$HOME/.mplayer/config"

        if grep -qs "^vo_driver =" "$HOME/.mplayer/gui.conf" ; then
            sed -i "s/^vo_driver.*$/vo_driver = \"x11\"/g" "$HOME/.mplayer/gui.conf"
        else
            echo "vo_driver = \"x11\"" >> "$HOME/.mplayer/gui.conf"
        fi

        if grep -qsE "^(vo=|#vo=)" "$HOME/.mplayer/config" ; then
            sed -i "s|^#vo=.*$|vo=x11|g" "$HOME/.mplayer/config"
            sed -i "s|^vo=.*$|vo=x11|g" "$HOME/.mplayer/config"
        else
            echo "vo=x11" >> "$HOME/.mplayer/config"
        fi
        if grep -qsE "^(zoom=|#zoom=)" "$HOME/.mplayer/config" ; then
            sed -i "s|^#zoom=.*$|zoom=yes|g" "$HOME/.mplayer/config"
            sed -i "s|^zoom=.*$|zoom=yes|g" "$HOME/.mplayer/config"
        else
            echo -e "zoom=yes" >> "$HOME/.mplayer/config"
        fi
    fi

    # disable battery emodule if the battery is broken
    if LC_ALL=C acpi 2>&1 | grep -qsE "\s+0%$" || LC_ALL=C acpi 2>&1 | grep -qsE "No support for.*power_supply" ; then
        enlightenment_remote -module-disable battery
        enlightenment_remote -module-unload battery
    fi


    sync ; sleep 1
    enlightenment_remote -save


    # if we are debugging give it a little pause to see what is going on
    if grep -qs "debug" /proc/cmdline ; then
        echo -e "debug: sleep 2" 1>&2
    fi
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :

