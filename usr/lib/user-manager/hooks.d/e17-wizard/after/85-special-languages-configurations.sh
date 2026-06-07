#!/bin/bash
SOURCE="$0"
source /usr/lib/elive-tools/functions
EL_REPORTS="1"
el_make_environment
. gettext.sh
TEXTDOMAIN="elive-tools"
export TEXTDOMAIN




suggest_emodule_flag_keyboard(){
    # do not annoy with suggestions in live mode
    if grep -Fqs "boot=live" /proc/cmdline ; then
        return 0
    fi

    # e27 -> enlightenment
    # if el_user_desktop_running enlightenment ; then
        local message_suggestion_flag
        message_suggestion_flag="$( printf "$( eval_gettext "Tip: Your country has different keyboard layouts; if you want fast switching between different language layouts, right-click on the shelf in the corner to add the keyboard gadget." )" "" )"

        if ! [[ "$MACHINE_VIRTUAL" = "yes" ]] ; then
            zenity --info --text="$message_suggestion_flag"
        fi
    # else
    #     # e16
    #     true
    #     # zenity --info --text="$( eval_gettext "" )" "" || true
    # fi
}


main(){
    # pre {{{
    local language

    # debug mode
    if grep -Fqs "debug" /proc/cmdline ; then
        export EL_DEBUG=3
        if grep -Fqs "completedebug" /proc/cmdline ; then
            set -x
        fi
    fi


    # know virtualized state
    source /etc/elive/machine-profile 2>/dev/null || true
     # }}}

    source /etc/default/locale

    # different installs based in different languages
    case "$LANG" in
        ko_KR*)
            language="Korean"
            package="fcitx5-hangul"
            suggest_emodule_flag_keyboard
            ;;
        ja_JP*)
            language="Japanese"
            package="fcitx5-mozc|fcitx5-anthy"
            suggest_emodule_flag_keyboard
            ;;
        zh_CN*|zh_TW*)
            language="Chinese"
            local message_instructions_extra
            message_instructions_extra="$( printf "$( eval_gettext "Use the Package Manager to install one of the suggested options supporting Chinese typing input in different ways:" )" " fcitx5-chinese-addons, fcitx5-chewing, fcitx5-pinyin, fcitx5-sunpinyin" )"
            suggest_emodule_flag_keyboard
            ;;
        vi_VN*)
            language="Vietnamese"
            package="fcitx5-unikey"
            suggest_emodule_flag_keyboard
            ;;
        th_TH*)
            language="Thai"
            package="fcitx5-thai"
            suggest_emodule_flag_keyboard
            ;;
        hi_IN*|bn_IN*|gu_IN*|kn_IN*|ml_IN*|mr_IN*|pa_IN*|ta_IN*|te_IN*)
            language="Indic"
            package="fcitx5-m17n"
            suggest_emodule_flag_keyboard
            ;;
        ar_*)
            language="Arabic"
            package="fcitx5-table-extra"
            suggest_emodule_flag_keyboard
            ;;
        he_IL*)
            language="Hebrew"
            suggest_emodule_flag_keyboard
            ;;
        *_CA*|*_CH*|*_CM*|*_MA*|*_CD*|*_GH*|*_GN*|*_RS*|*_SY*|*_TR*|*_ZA*|*_KE*|*_AF*|*_BR*|*_HR*|*_CZ*|*_IR*|*_FI*|*_FR*|*_GE*|*_DE*|*_HU*|*_KZ*|*_NO*|*_PL*|*_ES*|*_SE*|*_UK*|*_PK*|*_NG*|*_ML*|*_BE*|*_IT*|*_PT*|*_RO*)
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
        # ensure base fcitx5 and frontends are included
        package="fcitx5|fcitx5-frontend-gtk2|fcitx5-frontend-gtk3|fcitx5-frontend-qt5|fcitx5-config-qt|${package}"

        # messages
        local message_asking
        message_asking="$( printf "$( eval_gettext "Do you want to add support for %s keyboard input to your Elive system?" )" "$language" )"

        local message_instructions

        # desktop message
        if [[ -n "$EROOT" ]] ; then
            message_instructions="$( printf "$( eval_gettext "To be able to type in %s, you need to change your input to '%s'. Help us improving the support of your language into Elive telling us in the Elive forums what is missing to configure. You can swith it pressing the Hotkeys '%s'" )" "${language}" "Fcitx5" "Alt + Space" )"
        else
            message_instructions="$( printf "$( eval_gettext "To be able to type in %s, you need to change your keyboard layout to '%s'. You can find the keyboard layout settings by typing '%s' in the launcher. Or in %s. In the opened settings, select the '%s' button and then '%s'. Finally, select the '%s' and start the daemon, then select the %s language in the second tab and the Add button. When everything is done, open a graphical application and press '%s' to switch to your %s keyboard." )" "${language}" "Fcitx5" "Fcitx5 Configuration" "Menu -> Settings -> Language -> Input Methods" "System" "fcitx5" "Setup Option" "${language}" "Alt + Space" "${language}"  )"
        fi

        # install
        if zenity --question --text="$message_asking" ; then
            # install
            if [[ -n "$package" ]] ; then
                el_dependencies_install "$package"
            fi

            # run the daemon and setup
            mkdir -p "$HOME/.config/fcitx5"
            if [[ ! -f "$HOME/.config/fcitx5/config" ]] ; then
                {
                    echo "[Hotkey/TriggerKeys]"
                    echo "0=Alt+space"
                } > "$HOME/.config/fcitx5/config"
            else
                if grep -q "\[Hotkey/TriggerKeys\]" "$HOME/.config/fcitx5/config" ; then
                    sed -i '/\[Hotkey\/TriggerKeys\]/,/^\[/ s/^[0-9]=.*/0=Alt+space/' "$HOME/.config/fcitx5/config"
                else
                    {
                        echo ""
                        echo "[Hotkey/TriggerKeys]"
                        echo "0=Alt+space"
                    } >> "$HOME/.config/fcitx5/config"
                fi
            fi

            # Set fcitx5 as the default input method
            if command -v im-config >/dev/null ; then
                im-config -n fcitx5
            fi

            fcitx5-configtool

            # instructions
            zenity --info --text="$message_instructions" || true

            # demo typing
            export GTK_IM_MODULE="fcitx"
            export QT_IM_MODULE="fcitx"
            export XMODIFIERS="@im=fcitx"
            export ECORE_IMF_MODULE="fcitx"

            # make them persistent for the user
            if ! grep -q "GTK_IM_MODULE=fcitx" "$HOME/.profile" ; then
                {
                    echo ""
                    echo "# Fcitx5 configuration for $language"
                    echo "export GTK_IM_MODULE=fcitx"
                    echo "export QT_IM_MODULE=fcitx"
                    echo "export XMODIFIERS=@im=fcitx"
                    echo "export ECORE_IMF_MODULE=fcitx"
                } >> "$HOME/.profile"
            fi

            zenity --entry --text="$( eval_gettext "Switch to the new keyboard layout and type here to test." )" || true

            # final note
            zenity --info --text="$( eval_gettext "You can install multiple Fcitx5 packages to support your language. If you find a better alternative, please report it to Elive so it can be implemented and work for everyone." )" || true
        fi

        # add package in installed system
        if grep -Fqs "boot=live" /proc/cmdline ; then
            while read -ru 3 line
            do
                echo "$line" >> /tmp/.packages-to-install
            done 3<<< "$( echo "$package" | tr ',' '\n' )"
        fi
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
