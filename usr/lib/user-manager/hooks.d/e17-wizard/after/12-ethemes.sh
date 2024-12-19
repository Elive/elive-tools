#!/bin/bash
SOURCE="$0"
source /usr/lib/elive-tools/functions
EL_REPORTS="1"
el_make_environment
. gettext.sh
TEXTDOMAIN="elive-tools"
export TEXTDOMAIN

main(){
    # debug mode
    # if grep -Fqs "debug" /proc/cmdline ; then
    #     export EL_DEBUG=3
    #     if grep -Fqs "completedebug" /proc/cmdline ; then
    #         set -x
    #     fi
    # fi

    if [ -n "$EROOT" ] ; then
        # e16
        true
    else
        # enlightenment
        if [ -n "$E_START" ] && [ -z "$E_HOME_DIR" ] ; then
            E_HOME_DIR="$HOME/.e/e17"
        fi

        if [ -n "$E_START" ] && [ -n "$( which enlightenment_remote )" ] ; then
            local message_title
            message_title="$( printf "$( eval_gettext "Design Selection" )" "" )"
            local message_message
            message_message="$( printf "$( eval_gettext "Select the design that you want" )" "" )"
            local message_design_elm_default
            message_design_elm_default="$( printf "$( eval_gettext "Default E flat theme" )" "" )"
            local message_elm_elive_light
            message_elm_elive_light="$( printf "$( eval_gettext "E17 Elive theme" )" "" )"
            local message_elm_elive_light_unfinished
            message_elm_elive_light_unfinished="$( printf "$( eval_gettext "(unfinished / bugged)" )" "" )"
            local message_color_palette
            message_color_palette="$( printf "$( eval_gettext "Color palette" )" "" )"



            # select a design
            result="$( $guitool --list \
                --title="${message_title}" \
                --text="${message_message}" \
                --column="option" \
                --hide-column=1 \
                --column="Design" \
                "1" \
                "${message_design_elm_default} + ${message_color_palette} Light" \
                "2" \
                "${message_design_elm_default} + ${message_color_palette} Dark" \
                "3" \
                "${message_design_elm_default} + ${message_color_palette} Mauve-Sunset" \
                "4" \
                "${message_elm_elive_light} ${message_elm_elive_light_unfinished} + ${message_color_palette} Light" \
                --height=220 \
                --width=480 || echo cancel )"

            case "$result" in
                "1")
                    # default E flat theme + light color palette
                    elementary_config -q -p "light"
                    if ! enlightenment_remote -theme-get | grep -q "/default.edj$" ; then
                        enlightenment_remote -theme-set "/usr/share/elementary/themes/default.edj"
                    fi
                    ;;
                "1")
                    # default E flat theme + dark color palette
                    elementary_config -q -p "default"
                    if ! enlightenment_remote -theme-get | grep -q "/default.edj$" ; then
                        enlightenment_remote -theme-set "/usr/share/elementary/themes/default.edj"
                    fi
                    ;;
                "3")
                    # default E flat theme
                    elementary_config -q -p "mauve-sunset"
                    if ! enlightenment_remote -theme-get | grep -q "/default.edj$" ; then
                        enlightenment_remote -theme-set "/usr/share/elementary/themes/default.edj"
                    fi
                    ;;
                "4")
                    # E17 Elive theme
                    elementary_config -q -p "light"
                    if ! enlightenment_remote -theme-get | grep -q "/Elive Light.edj$" ; then
                        enlightenment_remote -theme-set "/usr/share/elementary/themes/Elive Light.edj"
                    fi
                    ;;
                *)
                    # cancel
                    ;;
            esac


            # save
            sync ; sleep 1
            enlightenment_remote -save
        fi
    fi
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :

