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

    # Audio configurations {{{
    if ! [[ -s "$HOME/.asoundrc" ]] ; then
        # special cases, having a .asoundr doesn't works in other non-elive systems
        if [[ -e "$DHOME/.shared-home" ]] ; then
            el_explain 0 "home is shared"
            $guitool --warning --text="$( eval_gettext "Your home folder is shared with another system so we will not configure your audio card in order to have it working on your other system too, you should have it working in your Elive by default, but if is not the case run the audio-configurator application and it will create a file in your home directory called '.asoundrc' (which starts with a dot) to make your audio working, if your audio then doesn't work in your other operating system then you should need to delete it." ) - Or delete the file $HOME/.shared-home"

        else

            el_explain 0 "Configuring audio cards..."
            audio-configurator --quiet --auto --smart

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

    # import gnupg keys
    el_explain 0 "Importing Elive gpg key..."

    if [[ -d "/usr/share/elive-security" ]] && ! grep -qs "boot=live" /proc/cmdline ; then
        if el_dependencies_check gpg ; then
            gpg --import /usr/share/elive-security/*.asc
        fi
    fi

    # }}}

    # tell the user that many popups are coming...
    if ! grep -qs "boot=live" /proc/cmdline ; then
        $guitool --info --text="$( eval_gettext "Before you start using your new desktop, we need to configure a few things to improve your user experience..." )"
    fi

    # if we are debugging give it a little pause to see what is going on
    #if grep -qs "debug" /proc/cmdline ; then
        #echo -e "debug: sleep 4" 1>&2
        #sleep 4
    #fi

}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
