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
            message_instructions_extra="$( printf "$( eval_gettext "You must first install from the Package Manager one of the suggested options that supports Chinese input in different ways:" )" " ibus-cangjie, ibus-chewing, ibus-pinyin, ibus-sunpinyin" )"
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
        message_asking="$( printf "$( eval_gettext "Do you want to add support for %s keyboard input in your Elive system?" )" "$language" )"

        local message_instructions
        message_instructions="$( printf "$( eval_gettext "To be able to type in %s, you need to change your keyboard input to '%s'. You can found this option typing '%s' in the launcher. Or in %s. Inside these settings you must select the '%s' button and then '%s', finally select the '%s' and start the daemon, then select the %s language in the second tab. Now you just need to open a graphical application and press '%s' to switch to your %s keyboard." )" "${language}" "Ibus" "Input Method Settings" "Menu -> Settings -> Language -> Input Methods" "System" "ibus" "Setup Option" "${language}" "Ctrl + Space" "${language}"  )"

        # install
        if zenity --question --text="$message_asking" ; then
            # install
            if [[ -n "$package" ]] ; then
                if ! el_dependencies_check "$package" ; then
                    el_dependencies_install "$package"
                fi
            fi
            # instructions
            zenity --info --text="$message_instructions"
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
