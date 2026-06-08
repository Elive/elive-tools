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
    lang="$LANG"

    if [[ "$LANG" = "en_US"* ]] ; then
        # if the language is english, try to guess the country of the user to suggest a better input method
        if el_verify_internet ; then
            location="$( showmylocation )"
            # location_country_code example: "VN" for vietnam
            location_country_code="$( echo "$location" | awk -F"::" '/country_code/ {print $2}' | tail -1 )"
            if [[ -n "$location_country_code" ]] ; then
                case "$location_country_code" in
                    KR) lang="ko_KR" ; ;;
                    JP) lang="ja_JP" ; ;;
                    CN) lang="zh_CN" ; ;;
                    TW) lang="zh_TW" ; ;;
                    VN) lang="vi_VN" ; ;;
                    TH) lang="th_TH" ; ;;
                    IN) lang="hi_IN" ; ;;
                    IL) lang="he_IL" ; ;;
                    IR) lang="fa_IR" ; ;;
                    KH) lang="km_KH" ; ;;
                    LA) lang="lo_LA" ; ;;
                    LK) lang="si_LK" ; ;;
                    ET) lang="am_ET" ; ;;
                    PH) lang="fil_PH" ; ;;
                    *) ;;
                esac
            fi
        fi
    fi

    # different installs based in different languages
    case "$lang" in
        ko_KR*)
            language="Korean"
            package="fcitx5-hangul"
            fcitx_engine="hangul"
            suggest_emodule_flag_keyboard
            ;;
        ja_JP*|en_JP*)
            language="Japanese"
            package="fcitx5-mozc|fcitx5-anthy"
            fcitx_engine="mozc"
            suggest_emodule_flag_keyboard
            ;;
        zh_CN*|zh_TW*)
            language="Chinese"
            local message_instructions_extra
            message_instructions_extra="$( printf "$( eval_gettext "Use the Package Manager to install one of the suggested options supporting Chinese typing input in different ways:" )" " fcitx5-chinese-addons, fcitx5-chewing, fcitx5-pinyin, fcitx5-sunpinyin" )"
            fcitx_engine="pinyin"
            suggest_emodule_flag_keyboard
            ;;
        vi_VN*)
            language="Vietnamese"
            package="fcitx5-unikey"
            fcitx_engine="unikey"
            suggest_emodule_flag_keyboard
            ;;
        th_TH*)
            language="Thai"
            package="fcitx5-thai"
            fcitx_engine="thai"
            suggest_emodule_flag_keyboard
            ;;
        hi_IN*|bn_IN*|gu_IN*|kn_IN*|ml_IN*|mr_IN*|pa_IN*|ta_IN*|te_IN*)
            language="Indic"
            package="fcitx5-m17n"
            fcitx_engine="m17n"
            suggest_emodule_flag_keyboard
            ;;
        ar_*)
            language="Arabic"
            package="fcitx5-table-extra"
            fcitx_engine="table"
            suggest_emodule_flag_keyboard
            ;;
        he_IL*)
            language="Hebrew"
            suggest_emodule_flag_keyboard
            ;;
        fa_IR*)
            language="Persian"
            package="fcitx5-table-extra|fcitx5-m17n"
            fcitx_engine="table"
            suggest_emodule_flag_keyboard
            ;;
        km_KH*)
            language="Khmer"
            package="fcitx5-m17n"
            fcitx_engine="m17n"
            suggest_emodule_flag_keyboard
            ;;
        lo_LA*)
            language="Lao"
            package="fcitx5-m17n"
            fcitx_engine="m17n"
            suggest_emodule_flag_keyboard
            ;;
        si_LK*)
            language="Sinhala"
            package="fcitx5-m17n"
            fcitx_engine="m17n"
            suggest_emodule_flag_keyboard
            ;;
        am_ET*)
            language="Amharic"
            package="fcitx5-m17n"
            fcitx_engine="m17n"
            suggest_emodule_flag_keyboard
            ;;
        *_CA*|*_CH*|*_CM*|*_MA*|*_CD*|*_GH*|*_GN*|*_RS*|*_SY*|*_TR*|*_ZA*|*_KE*|*_AF*|*_BR*|*_HR*|*_CZ*|*_IR*|*_FI*|*_FR*|*_GE*|*_DE*|*_HU*|*_KZ*|*_NO*|*_PL*|*_ES*|*_SE*|*_UK*|*_PK*|*_NG*|*_ML*|*_BE*|*_IT*|*_PT*|*_RO*|*_LU*|*_PH*|*_IE*|*_LV*|*_LT*|*_EE*)
            # countries with multiple layouts, info from /usr/share/doc/keyboard-configuration/xorg.lst
            # canada, swiss, cameroon, morocco, congo, ghana, guinea, serbia, syria, turkish, south africa, kenya, afghanistan, brazil, croatia, czech, iran, finland, france, georgia, germany, hungary, kazakshtan, norwegian, polish, spain, sweden, ukrania, pakistan, nigeria, mali, luxembourg, philippines, ireland, latvia, lithuania, estonia
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
            message_instructions="$( printf "$( eval_gettext "To switch betwen keyboard layouts and %s, you can click the small icon in the corner or press the Hotkeys '%s'. Help us improving the support of your language into Elive telling us in the Elive forums what is missing to configure." )" "${language}" "Alt + Space" )"
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

            # Pre-configure the input engine
            if [[ -n "$fcitx_engine" ]] && [[ ! -f "$HOME/.config/fcitx5/profile" ]] ; then
                {
                    echo "[Groups/0]"
                    echo "Name=Default"
                    echo "Default Layout=us"
                    echo "DefaultIM=keyboard-us"
                    echo ""
                    echo "[Groups/0/Items/0]"
                    echo "Name=${fcitx_engine}"
                    echo "Layout="
                    echo ""
                    echo "[Groups/0/Items/1]"
                    echo "Name=keyboard-us"
                    echo "Layout="
                    echo ""
                    echo "[GroupOrder]"
                    echo "0=Default"
                } > "$HOME/.config/fcitx5/profile"
            fi

            # run daemon
            ( fcitx5 & )
            LC_ALL=C  sleep 0.3
            # config frontend
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
