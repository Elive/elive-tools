#!/bin/bash
SOURCE="$0"
source /usr/lib/elive-tools/functions
el_make_environment
. gettext.sh
TEXTDOMAIN="elive-tools"
export TEXTDOMAIN


suggest_emodule_flag_keyboard(){
    local message_suggestion_flag
    message_suggestion_flag="$( printf "$( eval_gettext "Tip: Your country uses different keyboard layouts. If you want to switch between different language keyboards fastly, right click in the shelf of the bottom right corner to add as content the keyboard gadget." )" "" )"

    zenity --info --text="$message_suggestion_flag"
}


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
            suggest_emodule_flag_keyboard
            ;;
        ja_JP*)
            language="Japanese"
            package="ibus-anthy,ibus-mozc"
            suggest_emodule_flag_keyboard
            ;;
        zh_CN*|zh_TW*)
            language="Chinese"
            local message_instructions_extra
            message_instructions_extra="$( printf "$( eval_gettext "Use the Package Manager first to install one of the suggested options supporting Chinese input in different ways:" )" " ibus-cangjie, ibus-chewing, ibus-pinyin, ibus-sunpinyin" )"
            suggest_emodule_flag_keyboard
            ;;
        vi_VN*)
            language="Vietnamese"
            package="ibus-unikey"
            suggest_emodule_flag_keyboard
            ;;
        *_CA*|*_CH*|*_CM*|*_MA*|*_CD*|*_GH*|*_GN*|*_RS*|*_SY*|*_TR*|*_ZA*|*_KE*|*_AF*|*_BR*|*_HR*|*_CZ*|*_IR*|*_FI*|*_FR*|*_GE*|*_DE*|*_HU*|*_KZ*|*_NO*|*_PL*|*_ES*|*_SE*|*_UK*|*_PK*|*_NG*|*_ML*)
            # countries with multiple layouts, info from /usr/share/doc/keyboard-configuration/xorg.lst
            # canada, swiss, cameroon, morocco, congo, ghana, guinea, serbia, syria, turkish, south africa, kenya, afghanistan, brazil, croatia, czech, iran, finland, france, georgia, germany, hungary, kazakshtan, norwegian, polish, spain, sweden, ukrania, pakistan, nigeria, mali
            suggest_emodule_flag_keyboard
            ;;
        *_RU*)
            # russia has many different layouts!
            suggest_emodule_flag_keyboard
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
            zenity --entry --text="$( eval_gettext "Switch to the new keyboard layout and type in any text here." )" || true

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
