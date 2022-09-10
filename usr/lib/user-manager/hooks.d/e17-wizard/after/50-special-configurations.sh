#!/bin/bash
SOURCE="$0"
source /usr/lib/elive-tools/functions
EL_REPORTS="1"
#el_make_environment
#. gettext.sh
#TEXTDOMAIN=""
#export TEXTDOMAIN


main(){
    # pre {{{
    # include sbin in our PATH since its needed sometimes, and there's nothing wrong by using it!
    #if [[ "$PATH" != *"/usr/sbin"* ]] ; then
        ## needed for: iwconfig
        #export PATH="${PATH}:/usr/local/sbin:/usr/sbin:/sbin"
    #fi


    # }}}

    RAM_TOTAL_SIZE_bytes="$(grep MemTotal /proc/meminfo | tr ' ' '\n' | grep "^[[:digit:]]*[[:digit:]]$" | head -1 )"
    RAM_TOTAL_SIZE_mb="$(( $RAM_TOTAL_SIZE_bytes / 1024 ))"
    RAM_TOTAL_SIZE_mb="${RAM_TOTAL_SIZE_mb%.*}"

    # disable XV rendering if we cannot use it
    if [[ -x "$(which xvinfo)" ]] ; then
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
                echo "zoom=yes" >> "$HOME/.mplayer/config"
            fi

            sed -i -e 's|^driver\\vo.*|driver\\vo=x11|g' "$HOME/.config/smplayer/smplayer.ini" 2>/dev/null
        fi
    else
        el_warning "no XV info found (xvinfo command)"
    fi

    # vaapi opitmized rendering?
    # update: libmpv stills a much better option
    #if [[ -x "$(which vainfo )" ]] ; then
        #if LC_ALL=C vainfo | grep -qs "vainfo: Driver version: " ; then
            #sed -i -e 's|^driver\\vo.*|driver\\vo=vaapi|g' "$HOME/.config/smplayer/smplayer.ini" 2>/dev/null
            ## depends on mpv
            #sed -i -e 's|^mplayer_bin=.*|mplayer_bin=mpv|g' "$HOME/.config/smplayer/smplayer.ini" 2>/dev/null
        #fi
    #fi


    # change conky network configuration
    if ! grep -qs "boot=live" /proc/cmdline ; then
    # in Live mode we configure it too but from deliver, in delayed_actions
        if [[ -e "$HOME/.conkyrc" ]] ; then
            if pidof conky 1>/dev/null ; then
                killall conky
                is_restart_needed_conky=1
            fi

            if el_verify_internet ; then
                iface="$( grep "1" /sys/class/net/*/carrier 2>/dev/null | grep -v "/net/lo/" | sed -e 's|/carrier.*$||g' -e 's|^.*/||g' | head -1 )"
                if [[ -n "$iface" ]] ; then
                    case "$iface" in
                        eth*|enp*)
                            # ETH lan cable networks, disable wifi features
                            sed -i -e "s|^\(ESSID.*\)$|#\1|gI" "$HOME/.conkyrc"
                            sed -i -e "s|^\(Connection quality.*\)$|#\1|gI" "$HOME/.conkyrc"
                            sed -i -e "s|wlan0|$iface|g" "$HOME/.conkyrc"
                            ;;
                        lo)
                            true
                            ;;
                        *)
                            # change iface to our used one
                            # update: this is not needed, but we need to have the network already set up from wlan before to run this, so it will probably run only when the system is installed
                            #iface="$( iwconfig 2>/dev/null | grep IEEE | awk '{print $1}' | head -1 )"
                            #if [[ -z "$iface" ]] ; then
                                #iface="wlan0"
                            #fi
                            sed -i -e "s|wlan0|$iface|g" "$HOME/.conkyrc"
                            ;;
                    esac
                fi
            fi

            # change interval if computer is slow
            if [[ "$RAM_TOTAL_SIZE_mb" -lt 2300 ]] ; then
                # reduce time interval
                #sed -i -e "s|^update_interval.*$|update_interval 4.0|gI" "$HOME/.conkyrc"
                sed -i -e "s|^.*update_interval.*$|\tupdate_interval = 4.0,|gI" "$HOME/.conkyrc"
            fi

            if ((is_restart_needed_conky)) ; then
                el_debug "restarting conky"
                killall conky
                ( conky 1>/dev/null 2>&1 & disown )
            fi
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

