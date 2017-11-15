#!/bin/bash
source /usr/lib/elive-tools/functions
# gettext not works here because we are on first page

main(){
    # pre {{{
    #local file

    # }}}

    # reconfigure GL in elementary based in E configurations
    if [[ -d "$HOME/.elementary/config/standard" ]] ; then
        cd_previous="$(pwd)"
        if [[ -z "$E_CONF_PROFILE" ]] ; then
            E_CONF_PROFILE="standard"
        fi
        if [[ -d "$HOME/.e/e17" ]] ; then
            E_DIR="$HOME/.e/e17/config/$E_CONF_PROFILE"
        else
            E_DIR="$HOME/.e/e/config/$E_CONF_PROFILE"
        fi

        cd "$E_DIR"
        eet -d e.cfg config e.cfg.src
        eet -d module.comp.cfg config module.comp.cfg.src

        #engine 2 is GL, 1 is software-mode
        if grep -qs "\"use_composite\" int: 1" "e.cfg.src" && grep -qs "\"engine\" int: 2" "module.comp.cfg.src" ; then
            accel_mode="gl"
            el_debug "using GL mode"
        else
            accel_mode="software"
            el_debug "using software mode"
        fi

        rm -f e.cfg.src module.comp.cfg.src
        cd "$cd_previous"


        cd "$HOME/.elementary/config/standard"

        eet -d base.cfg config base.cfg.src
        case "$accel_mode" in
            gl)
                sed -i -e "s|^.*value \"accel\" string.*$|   value \"accel\" string: \"gl\";|g" base.cfg.src
                sed -i -e "s|^.*value \"vsync\" uchar.*$|   value \"vsync\" uchar: 1;|g" base.cfg.src
                ;;
            software)
                sed -i -e "s|^.*value \"accel\" string.*$|   value \"accel\" string: \"none\";|g" base.cfg.src
                sed -i -e "s|^.*value \"vsync\" uchar.*$|   value \"vsync\" uchar: 0;|g" base.cfg.src
                ;;
        esac
        eet -e base.cfg config base.cfg.src 1
        rm -f base.cfg.src

        cd

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
