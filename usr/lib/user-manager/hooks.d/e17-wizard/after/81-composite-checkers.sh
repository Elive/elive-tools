#!/bin/bash
source /usr/lib/elive-tools/functions
#el_make_environment
# gettext functions
if [[ -x "/usr/bin/gettext.sh" ]] ; then
    . gettext.sh
else
    # make it compatible
    eval_gettext(){
        echo "$@"
    }
fi
TEXTDOMAIN="elive-tools"
export TEXTDOMAIN


main(){
    # pre {{{
    local file dir temp

    # already shown, ignore
    if el_flag check "composite-details" ; then
        return
    fi

    # }}}

    # virtualized? {{{
    if [[ -e "/etc/elive/machine-profile" ]] ; then
        source /etc/elive/machine-profile
    fi
    # }}}

    # e16 {{{
    if [[ -n "$EROOT" ]] ; then

        if zenity --question --text="$( eval_gettext "Do you want to enable composite layer? It will give you transparencies and a nicer looking desktop." )" ; then
            eesh compmgr start
            is_composite_e16_started=1
        else
            eesh compmgr stop
        fi

        if eesh -w "compmgr ?" | grep -qs "on=1" ; then
            zenity --info --text="$( eval_gettext "Composite in E16 should give you a better experience,  but if you see any issue or a reason to not enable it by default in Elive in the future, please share your comments in our forums. You can disable it in any moment from the configurations." )"
        else
            # report if failed
            if ((is_composite_e16_started)) ; then
                el_warning "User wanted to enable composite but it failed? $(lspci | grep VGA)"
            fi
        fi
    fi

    # }}}
    # e17 {{{
    if [[ -n "$E_START" ]] ; then
        # default E profile of user
        dir="${HOME}/.e/e17/config/$(enlightenment_remote -default-profile-get)"

        if [[ ! -d "$dir" ]] ; then
            el_warning "Unable to get default E profile of user, switching to default one"
            dir="${HOME}/.e/e17/config/standard"
        fi
        if [[ ! -d "$dir" ]] ; then
            el_error "Where is the default E profile of user? exiting..."
            exit
        fi

        # get file
        file="${dir}/module.comp.cfg"
        if [[ ! -s "$file" ]] ; then
            # if not exist, most probably is because we have it disabled (no composite at all selected)
            el_debug "E composite conf not found, ignoring..."
            exit
        fi

        # extract file
        temp="$(mktemp --suffix .src )"
        eet -d "$file" config "$temp"


        # show some info to the users
        value="$( grep 'value "engine"' "$temp" | sed -e 's|^.*: ||g' -e 's|;.*$||g' | tail -1 )"
        case "$value" in
            1)
                local message_gl
                message_gl="$( printf "$( eval_gettext "No desktop acceleration selected. This option is more stable, but it may result in a less responsive desktop, especially during video playback. If you did not try the accelerated mode yet, it is suggested to select it. You will be able to see, then , if it is compatible with your graphic card." )" )"

                if ! [[ "$MACHINE_VIRTUAL" = "yes" ]] ; then
                    zenity --info --text="$message_gl" || true
                fi
                ;;
            2)
                if [[ "$MACHINE_VIRTUAL" = "yes" ]] ; then
                    local message_vbox
                    message_vbox="$( printf "$( eval_gettext "The hardware acceleration mode may not work correctly in a virtual machine" )" "" )"
                    zenity --warning --text="$message_vbox"

                else
                    local message_gl
                    message_gl="$( printf "$( eval_gettext "Hardware acceleration makes your desktop more responsive and a smoother feeling, improves also the video playback speed and quality. But if the drivers for your graphic card are not correctly supported it can lead to a broken desktop or window visuals, to fix this you will need to switch to software mode in the composite options or disable the acceleration in a new desktop configuration." )" )"

                    zenity --info --text="$message_gl" || true

                    # vsync ?
                    if grep 'value "vsync"' "$temp" | sed -e 's|^.*: ||g' -e 's|;.*$||g' | tail -1 | grep -qs "1" ; then
                        true
                    else
                        local message_vsync_disabled
                        message_vsync_disabled="$( printf "$( eval_gettext "You did not select the %s option for composite (vertical synchronization). This option allows you to play videos perfectly smoothly and without horizontal lines. Go to the options panel, and in the options panel, go to the composite section." )" "vsync" )"
                        zenity --info --text="$message_vsync_disabled" || true
                    fi
                fi

                # intel card for wheezy?
                # update: not needed anymore
                #if lspci | grep VGA | grep -qs "Intel" ; then
                #if grep debian-version /etc/elive-version | grep -i wheezy ; then
                #local message_intel_buggy
                #message_intel_buggy="$( printf "$( eval_g
                #ettext "Note Intel cards: There's a known problem with the blanking (screensaver) powersavign feature on this version of the Intel drivers, which turns your desktop unrensponsive, if you really want automatic screen blanking you should use instead the software-mode of composite, but if you don't need it, just don't turn it on and everything else is fine." )" )"

                #zenity --info --text="$message_intel_buggy" || true
                #fi
                #fi

                ;;
        esac

        # cleanups
        rm -f "$temp"

    fi
    # end e17 }}}


    el_flag add "composite-details"


    # if we are debugging give it a little pause to see what is going on
    #if grep -qs "debug" /proc/cmdline ; then
        #echo -e "debug: sleep 2" 1>&2
        #sleep 2
    #fi
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
