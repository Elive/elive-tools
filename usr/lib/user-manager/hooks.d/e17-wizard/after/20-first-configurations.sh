#!/bin/bash
SOURCE="$0"
source /usr/lib/elive-tools/functions
EL_REPORTS="1"
el_make_environment
. gettext.sh
TEXTDOMAIN="elive-tools"
export TEXTDOMAIN
source /etc/default/locale

#el_make_environment
# gettext not works here because we are on first page
# set user home, so there's a bug
[[ -z $HOME ]] && export HOME="/home/$(id -un)"

main(){
    # pre {{{
    local var

    # }}}

    # precache desktops in BG while we wait for language to select {{{
    bash -c "precache --nice /etc/xdg/autostart/*desktop /usr/share/applications/*desktop /usr/share/xdgeldsk/applications/*desktopp $(which cairo-dock) $(which conky) $(which zenity) $(which yad) /usr/lib/notification-daemon/notification-daemon   1>/dev/null 2>&1  & disown"
    # - precache desktops }}}

    # Audio configurations {{{
    if ! [[ -s "$HOME/.asoundrc" ]] ; then
        # special cases, having a .asoundr doesn't works in other non-elive systems
        if [[ -e "$DHOME/.shared-home" ]] ; then
            el_explain 0 "home is shared"
            $guitool --warning --text="$( eval_gettext "Your user-home directory is shared with another system, so we will not configure your audio card in order to keep it working on the other system. If it doesn't work on Elive, run the audio-configurator application which will create a file in your home directory called '.asoundrc' (which starts with a dot) to get your audio working. Then if your audio doesn't work in the other operating system then you need to delete the file." ) - Or delete the file $HOME/.shared-home"

        else

            el_explain 0 "Configuring audio cards..."
            audio-configurator --quiet --auto --smart --no-messages

            # we need to create the PCM channel! it doesn't exist until we do it
            timeout 5 aplay /dev/null 2>/dev/null
            LC_ALL=C sleep 0.1
        fi
    fi

    el_explain 0 "Setting default volumes..."
    rm -f "$HOME/.config/setvolume" 2>/dev/null 1>&2
    setvolume defaults

    # - Audio configurations }}}
    # add elive gpg key {{{

    if grep -qs "boot=live" /proc/cmdline ; then
        is_live=1
    fi

    # import gnupg keys
    el_explain 0 "Importing Elive gpg key..."

    if [[ -d "/usr/share/elive-security" ]] && ! ((is_live)) ; then
        if el_dependencies_check gpg ; then
            gpg --import /usr/share/elive-security/*.asc
        fi
    fi

    # }}}

    # tell the user that many popups are coming...
    if ! ((is_live)) ; then
        $guitool --info --text="$( eval_gettext "Before you start using your new desktop, we need to configure a few things to improve your user experience..." )"
    fi

    # if we are debugging give it a little pause to see what is going on
    #if grep -Fqs "debug" /proc/cmdline ; then
        #echo -e "debug: sleep 4" 1>&2
        #sleep 4
    #fi

}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
