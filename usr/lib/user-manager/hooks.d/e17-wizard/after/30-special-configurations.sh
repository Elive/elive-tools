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

    # get the optimal font name
    #if enlightenment_remote -font-list | grep -qs "DejaVu Sans:" ; then
        #font="DejaVu Sans"
    #else
        #font="Sans"
    #fi

    ## automatically set the Font for applications in an optimal size based in the DPI:
    #enlightenment_remote -font-set-auto "application" "$font"


    #resolution="$( enlightenment_remote -resolution-get | sed -e 's|x.*$||g' )"
    #read -r resolution <<< "$resolution"

    ## set more specific font sizes for extreme cases
    #if [[ "$resolution" -gt 1024 ]] ; then
        ## not needed: we have it already set more optimally
        ##enlightenment_remote -font-set "application" "$font" 9
        #true
    #else
        #if [[ "$resolution" -ge 800 ]] ; then
            ## resolutions between 800x* & 1024x*
            #enlightenment_remote -font-set "application" "$font" 8
        #else
            #if [[ "$resolution" -lt 800 ]] ; then
                ## very extreme cases (very small screens)
                #enlightenment_remote -font-set "application" "$font" 7
            #fi
        #fi
    #fi

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

