#!/bin/bash
SOURCE="$0"
source /usr/lib/elive-tools/functions
el_make_environment
. gettext.sh
TEXTDOMAIN="elive-tools"
export TEXTDOMAIN



main(){
    # pre {{{
    local language

    # }}}
    source /etc/default/locale

    # different installs based in different languages
    case "$LANG" in
        ko_KR*)
            language="Korean"
            package="ibus-hangul"
            ;;
        ja_JP*)
            language="Japanese"
            package="ibus-anthy,ibus-mozc"
            ;;
        zh_CN*|zh_TW*)
            language="Chinese"
            local message_instructions_extra
            message_instructions_extra="$( printf "$( eval_gettext "Use the Package Manager first to install one of the suggested options supporting Chinese input in different ways:" )" " ibus-cangjie, ibus-chewing, ibus-pinyin, ibus-sunpinyin" )"
            ;;
        vi_VN*)
            language="Vietnamese"
            package="ibus-unikey"
            ;;
    esac


    # install support for language
    if [[ -n "$language" ]] ; then
        # messages
        local message_asking
        message_asking="$( printf "$( eval_gettext "Do you want to add support for %s keyboard input to your Elive system?" )" "$language" )"

        local message_instructions
        message_instructions="$( printf "$( eval_gettext "To be able to type in %s, you need to change your keyboard layout to '%s'. You can find the keyboard layout settings typing '%s' in the launcher. Or in %s. In these settings select the '%s' button and then '%s'. Finally select the '%s' and start the daemon, then select the %s language in the second tab and the Add button. Open a graphical application now and press '%s' to switch to your %s keyboard." )" "${language}" "Ibus" "Input Method Settings" "Menu -> Settings -> Language -> Input Methods" "System" "ibus" "Setup Option" "${language}" "Ctrl + Space" "${language}"  )"

        # install
        if zenity --question --text="$message_asking" ; then
            # install
            if [[ -n "$package" ]] ; then
                el_dependencies_install "$package"
            fi

            # instructions
            zenity --info --text="$message_instructions" || true

            # demo typing
            export GTK_IM_MODULE="ibus"
            export QT_IM_MODULE="ibus"
            export XMODIFIERS="@im=ibus"
            export ECORE_IMF_MODULE="ibus"
            zenity --entry --text="$( eval_gettext "Switch to the new keyboard layout and type any text in here." )" || true

            # final note
            zenity --info --text="$( eval_gettext "You can install multiple Ibus packages to support your language. If you find that there is a better alternative, please report it to Elive, so it can be implemented and work for everybody." )" || true
        fi

        # add package in installed system
        if grep -qs "boot=live" /proc/cmdline ; then
            while read -ru 3 line
            do
                echo "$line" >> /tmp/.packages-to-install
            done 3<<< "$( echo "$package" | tr ',' '\n' )"
        fi
    fi

    # if we are debugging give it a little pause to see what is going on
    if grep -qs "debug" /proc/cmdline ; then
        echo -e "debug: sleep 4" 1>&2
        sleep 4
    fi

}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
