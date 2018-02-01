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

    # }}}
    # already shown, ignore
    if el_flag check "composite-details" ; then
        return
    fi

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


    # get data

    value="$( grep 'value "engine"' "$temp" | sed -e 's|^.*: ||g' -e 's|;.*$||g' | tail -1 )"
    case "$value" in
        1)
            local message_gl
            message_gl="$( printf "$( eval_gettext "You have selected the software mode of composite. This option is more stable than the GL mode but it can make your desktop less responsive, especially during video playback, due to the higher demand on your CPU. We suggest you try to the GL mode to see if it works correctly with your graphic card. You can found it in the Composite settings of the Enlightenment preferences. Enabling VSYNC is strongly suggested to reproduce videos perfectly smooth without horizontal artifacts." )" )"

            if ! grep -qsi "system.hardware.product =.*VirtualBox" /tmp/.lshal ; then
                zenity --info --text="$message_gl"
            fi
            ;;
        2)
            if grep -qsi "system.hardware.product =.*VirtualBox" /tmp/.lshal ; then
                local message_vbox
                message_vbox="$( printf "$( eval_gettext "You cannot use the GL accelerated mode inside virtualbox" )" "" )"
                zenity --error --text="$message_vbox"

            else
                local message_gl
                message_gl="$( printf "$( eval_gettext "You have selected the GL mode of Composite. This is a good thing because it makes your desktop flow more smoothly with less lag. This could also interfere with rare graphic cards by blocking your computer, black screen or windows, unresponsive desktop returning from suspension or windows that disappear. If you see any of these problems or you want a more stable environment just use the software mode instead of GL. You can switch to software mode at any moment in the Enlightenment preferences." )" )"

                zenity --info --text="$message_gl"

                # vsync ?
                if grep 'value "vsync"' "$temp" | sed -e 's|^.*: ||g' -e 's|;.*$||g' | tail -1 | grep -qs "1" ; then
                    true
                else
                    local message_vsync_disabled
                    message_vsync_disabled="$( printf "$( eval_gettext "You didn't select the %s option for composite (vertical synchronization), this option allows you to play videos perfectly smooth and without horizontally cutting lines. You can enable this option in the Options panel, in the Composite section." )" "vsync" )"
                    zenity --info --text="$message_vsync_disabled"
                fi
            fi

            # intel card for wheezy?
            # update: not needed anymore
            #if lspci | grep VGA | grep -qs "Intel" ; then
                #if grep debian-version /etc/elive-version | grep -i wheezy ; then
                    #local message_intel_buggy
                    #message_intel_buggy="$( printf "$( eval_g
                #ettext "Note Intel cards: There's a known problem with the blanking (screensaver) powersavign feature on this version of the Intel drivers, which turns your desktop unrensponsive, if you really want automatic screen blanking you should use instead the software-mode of composite, but if you don't need it, just don't turn it on and everything else is fine." )" )"

                    #zenity --info --text="$message_intel_buggy"
                #fi
            #fi

            ;;
    esac


    el_flag add "composite-details"

    # cleanups
    rm -f "$temp"


    # if we are debugging give it a little pause to see what is going on
    if grep -qs "debug" /proc/cmdline ; then
        echo -e "debug: sleep 2" 1>&2
        sleep 2
    fi
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
