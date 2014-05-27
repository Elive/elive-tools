#!/bin/bash
source /usr/lib/elive-tools/functions

main(){
    # pre {{{
    local var

    # }}}

    # clean conf, so create it again in case that already exists
    rm -f "${XDG_CONFIG_HOME}"/user-dirs.*

    # create dirs and default conf file
    xdg-user-dirs-update
    xdg-user-dirs-gtk-update

    # source after to have created it
    #if [[ -z "${XDG_CONFIG_HOME}" ]] || [[ ! -d "$XDG_CONFIG_HOME" ]] ; then
        #XDG_CONFIG_HOME="${HOME}/.config"
    #fi
    #source "${XDG_CONFIG_HOME}/user-dirs.dirs"

    # delete Desktop entry, what a useless idea
    if [[ -d "$HOME/Desktop" ]] ; then
        rmdir "$HOME/Desktop" 2>/dev/null 1>&2 || true

        if [[ -d "$HOME/Desktop" ]] ; then
            mv "$HOME/Desktop" "$(xdg-user-dir DOWNLOAD)/"
        fi
    fi

    rmdir "$(xdg-user-dir DESKTOP )" 2>/dev/null 1>&2 || true

    sed -i "/^XDG_DESKTOP_DIR/d" "${XDG_CONFIG_HOME}/user-dirs.dirs"
    echo -e "XDG_DESKTOP_DIR=\"\$HOME/\"" >> "${XDG_CONFIG_HOME}/user-dirs.dirs"


    # delete Templates too
    rmdir "$(xdg-user-dir TEMPLATES )" 2>/dev/null 1>&2 || true
    sed -i "/^XDG_TEMPLATES_DIR/d" "${XDG_CONFIG_HOME}/user-dirs.dirs"
    echo -e "XDG_TEMPLATES_DIR=\"\$HOME/\"" >> "${XDG_CONFIG_HOME}/user-dirs.dirs"


    # update again and save results
    xdg-user-dirs-update
    xdg-user-dirs-gtk-update

    # Make the publicshare folder to be directly shared
    # net usershare add NAME DIR COMMENT ACL GUEST
    net usershare add "${USER}_$( basename "$(xdg-user-dir PUBLICSHARE )" )" "$(xdg-user-dir PUBLICSHARE )" "$USER Public directory in $HOSTNAME computer" Everyone:r guest_ok=yes   #2>/dev/null 1>&2 || true
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
