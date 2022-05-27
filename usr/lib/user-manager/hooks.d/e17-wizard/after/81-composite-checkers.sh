#!/bin/bash
SOURCE="$0"
source /usr/lib/elive-tools/functions
EL_REPORTS="1"
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

    # }}}

    # virtualized? {{{
    if [[ -e "/etc/elive/machine-profile" ]] ; then
        source /etc/elive/machine-profile
    fi
    # }}}

    # e16 {{{
    if [[ -n "$EROOT" ]] ; then

        # update: not needed, user don't needs this
        #if zenity --question --text="$( eval_gettext "Do you want to enable composite layer? It will give you transparencies and a nicer looking desktop." )" ; then
            #eesh compmgr start
            #is_composite_e16_started=1
        #else
            #eesh compmgr stop
        #fi

        # fix conky conf
        if [[ -e "$HOME/.conkyrc" ]] ; then
            if pidof conky 1>/dev/null ; then
                killall conky
                is_restart_needed_conky=1
            fi
            sync
            if eesh "compmgr ?" | grep -qs "on=1" ; then
                #sed -i -e "s|^.*own_window_argb_visual.*$|own_window_argb_visual yes|gI" "$HOME/.conkyrc"
                sed -i -e "s|^.*own_window_argb_visual.*$|\town_window_argb_visual = true,|gI" "$HOME/.conkyrc"
            else
                sed -i -e "s|^.*own_window_argb_visual.*$|\town_window_argb_visual = false,|gI" "$HOME/.conkyrc"
            fi
            if ((is_restart_needed_conky)) ; then
                el_debug "restarting conky"
                LC_ALL=C sleep 1
                ( conky 1>/dev/null 2>&1 & disown )
            fi
        fi


        # ask for specific resolution in virtual machines
        if [[ "$MACHINE_VIRTUAL" = "yes" ]] && ! grep -qs "boot=live" /proc/cmdline && ! [[ "$( find -type f "$HOME/.screenlayout/" 2>/dev/null | wc -l )" -gt 0 ]] ; then

            if $guitool --question --text="$( eval_gettext "Elive can remember a specific desired resolution for your virtual machine screen. Do you want to set for it a specific resolution?" )"  ; then
                elive-multiscreens -c
            fi
        fi
    fi

    # }}}

    # show a tip suggestion about resizing windows, needed for big-windows that appears out of hte borders (e16), but also useful for e17:
    if ! grep -qs "thanatests" /proc/cmdline ; then
        notify-send -u low -t 15000 -i "gtk-help" "$( eval_gettext "Suggestion" )" "$( eval_gettext "To move and resize a window, use the combination 'ctrl+alt' and click with the different mouse buttons while moving it." )"
    fi

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
                message_gl="$( printf "$( eval_gettext "Hardware-accelerated desktop not in use. This option is more stable but may result in a slower desktop, especially during video playback. If you haven't tried the accelerated mode yet, we recommend to try it. You will then see whether it is compatible with your graphics card." )" )"

                if ! [[ "$MACHINE_VIRTUAL" = "yes" ]] ; then
                    zenity --info --text="$message_gl" || true
                fi
                ;;
            2)
                if [[ "$MACHINE_VIRTUAL" = "yes" ]] ; then
                    local message_vbox
                    message_vbox="$( printf "$( eval_gettext "The hardware acceleration mode may not work correctly in a virtual machine." )" "" )"
                    zenity --warning --text="$message_vbox"

                else
                    local message_gl
                    message_gl="$( printf "$( eval_gettext "Hardware acceleration makes your desktop faster and feel smoother, it also improves video playback speed and usablity. If the drivers of your graphic card are not stable enough,, which can cause a broken desktop and/or visual artifacts. Fixing this will require switching to software mode in the compositor options or disabling the acceleration in a new desktop configuration." )" )"

                    zenity --info --text="$message_gl" || true

                    # vsync ?
                    if grep 'value "vsync"' "$temp" | sed -e 's|^.*: ||g' -e 's|;.*$||g' | tail -1 | grep -qs "1" ; then
                        true
                    else
                        local message_vsync_disabled
                        message_vsync_disabled="$( printf "$( eval_gettext "You did not select the %s option for composite (vertical synchronization). This option allows you to play videos smoothly and without horizontal lines. Go to the options panel, and in the panel, go to the composite section." )" "vsync" )"
                        zenity --info --text="$message_vsync_disabled" || true
                    fi
                fi

                # intel card for wheezy?
                # update: not needed anymore
                #if lspci | grep VGA | grep -qs "Intel" ; then
                #if grep debian_version /etc/elive-version | grep -i wheXXXXezy ; then
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

    # hardware check: broken bios? {{{
    if dmesg | grep -qsi "you might be running a broken BIOS" ; then
        local message_efiboot
        if el_check_dir_has_files "/sys/firmware/efi/" 1>/dev/null 2>&1 ; then
            message_efiboot="$( printf "$( eval_gettext "Note: Elive has a feature to install BIOS updates but for that, you need to reinstall Elive using the EFI boot mode in your BIOS." )" "" )"
        else
            message_efiboot=""
        fi
        local message_broken_bios
        message_broken_bios="$( printf "$( eval_gettext "A warning message has been found that your BIOS may be broken. If you experience any hardware issues we strongly recommend updating your BIOS. " )" "" )"

        $guitool --warning --text="${message_broken_bios} ${message_efiboot}" 1>/dev/null 2>&1 || true
    fi

    # }}}


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
