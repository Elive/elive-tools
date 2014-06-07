#!/bin/bash
source /usr/lib/elive-tools/functions

migrate_conf_file(){
    local file file_bkp
    file="$1"
    file_bkp="/tmp/.$(basename $0)-$USER-$(basename $file )"

    # debug info
    if [[ "$EL_DEBUG" -gt 2 ]] ; then
        cp "$file" "$file_bkp"
    fi


    # replacements {{{
    if grep -qs "$HOME/Desktop" "$file" 2>/dev/null ; then
        sed -i "s|$HOME/Desktop|$( xdg-user-dir DOWNLOAD )|g" "$file"
        el_explain 0 "Migrated references for __Desktop__ in __${file}__"
    fi
    # downloads needs to be after desktop, since desktop was the real downloads dir
    if grep -qs "$HOME/Downloads" "$file" 2>/dev/null ; then
        sed -i "s|$HOME/Downloads|$( xdg-user-dir DOWNLOAD )|g" "$file"
        el_explain 0 "Migrated references for __Downloads__ in __${file}__"
    fi

    if grep -qs "$HOME/Documents" "$file" 2>/dev/null ; then
        sed -i "s|$HOME/Documents|$( xdg-user-dir DOCUMENTS )|g" "$file"
        el_explain 0 "Migrated references for __Documents__ in __${file}__"
    fi

    if grep -qs "$HOME/Images" "$file" 2>/dev/null ; then
        sed -i "s|$HOME/Images|$( xdg-user-dir PICTURES )|g" "$file"
        el_explain 0 "Migrated references for __Images__ in __${file}__"
    fi

    if grep -qs "$HOME/Music" "$file" 2>/dev/null ; then
        sed -i "s|$HOME/Music|$( xdg-user-dir MUSIC )|g" "$file"
        el_explain 0 "Migrated references for __Music__ in __${file}__"
    fi

    if grep -qs "$HOME/Videos" "$file" 2>/dev/null ; then
        sed -i "s|$HOME/Videos|$( xdg-user-dir VIDEOS )|g" "$file"
        el_explain 0 "Migrated references for __Videos__ in __${file}__"
    fi


    # - replacements }}}

    # show debug to compare results
    if [[ "$EL_DEBUG" -gt 2 ]] ; then
        el_debug "Migrated conf file $file as:"

        if [[ -x "$(which colordiff)" ]] ; then
            diff "$file_bkp" "$file" | colordiff
        else
            diff "$file_bkp" "$file"
        fi
        rm -f "$file_bkp"
    fi
}

main(){
    # pre {{{
    local var

    # }}}
    if [[ -z "${XDG_CONFIG_HOME}" ]] || [[ ! -d "$XDG_CONFIG_HOME" ]] ; then
        XDG_CONFIG_HOME="${HOME}/.config"
    fi

    # clean conf, so create it again in case that already exists
    rm -f "${XDG_CONFIG_HOME}"/user-dirs.*

    # create dirs and default conf file
    xdg-user-dirs-update
    xdg-user-dirs-gtk-update

    # source after to have created it and dirs
    source "${XDG_CONFIG_HOME}/user-dirs.dirs"
    cd

    #
    # Desktop & Downloads
    #

    # if this is just a symlink (old deprecated dir), safe to remove like this
    rm -f "$HOME/Downloads" 2>/dev/null 1>&2 || true

    # delete Desktop entirely, what a useless idea
    if [[ -e "$HOME/Desktop" ]] ; then

        mv "$HOME/"Desktop/* "$( xdg-user-dir DOWNLOAD)/" 2>/dev/null || true
        rmdir "$HOME/Desktop" 2>/dev/null 1>&2 || true

        # if still exist, move it somewhere that doesn't annoy us
        if [[ -e "$HOME/Desktop" ]] ; then
            mv "$HOME/Desktop" "$(xdg-user-dir DOWNLOAD)/"
        fi

    fi

    # remove new xdg desktop dir too
    rmdir "$(xdg-user-dir DESKTOP )" 2>/dev/null 1>&2 || true

    # and never create it again
    sed -i "/^XDG_DESKTOP_DIR/d" "${XDG_CONFIG_HOME}/user-dirs.dirs"
    #echo -e "XDG_DESKTOP_DIR=\"\$HOME/\"" >> "${XDG_CONFIG_HOME}/user-dirs.dirs"
    # put it on the same place as downloads, not main homedir
    grep "^XDG_DOWNLOAD_DIR=" "${XDG_CONFIG_HOME}/user-dirs.dirs" | sed -e 's|_DOWNLOAD_|_DESKTOP_|g' >> "${XDG_CONFIG_HOME}/user-dirs.dirs"


    #
    # Templates
    #

    # delete Templates too, they are useless
    rmdir "$(xdg-user-dir TEMPLATES )" 2>/dev/null 1>&2 || true
    sed -i "/^XDG_TEMPLATES_DIR/d" "${XDG_CONFIG_HOME}/user-dirs.dirs"
    #echo -e "XDG_TEMPLATES_DIR=\"\$HOME/\"" >> "${XDG_CONFIG_HOME}/user-dirs.dirs"
    # put it on the same place as documents, not main homedir
    grep "^XDG_DOCUMENTS_DIR=" "${XDG_CONFIG_HOME}/user-dirs.dirs" | sed -e 's|_DOCUMENTS_|_TEMPLATES_|g' >> "${XDG_CONFIG_HOME}/user-dirs.dirs"


    #
    # Documents
    #

    if [[ -e "$HOME/Documents" ]] ; then
        mv "$HOME/"Documents/* "$( xdg-user-dir DOCUMENTS )/" 2>/dev/null || true

        rmdir "$HOME/Documents" 2>/dev/null 1>&2 || true

        # if still exist, move it somewhere that doesn't annoy us
        mv "$HOME/Documents" "$(xdg-user-dir DOCUMENTS )/" 2>/dev/null || true
    fi

    #
    # Music
    #

    if [[ -e "$HOME/Music" ]] ; then
        mv "$HOME/"Music/* "$( xdg-user-dir MUSIC )/" 2>/dev/null || true

        rmdir "$HOME/Music" 2>/dev/null 1>&2 || true

        # if still exist, move it somewhere that doesn't annoy us
        mv "$HOME/Music" "$(xdg-user-dir MUSIC )/" 2>/dev/null || true
    fi

    #
    # Images / Pictures
    #

    if [[ -e "$HOME/Images" ]] ; then
        mv "$HOME/"Images/* "$( xdg-user-dir PICTURES )/" 2>/dev/null || true

        rmdir "$HOME/Images" 2>/dev/null 1>&2 || true

        # if still exist, move it somewhere that doesn't annoy us
        mv "$HOME/Images" "$(xdg-user-dir PICTURES )/" 2>/dev/null || true
    fi

    #
    # Videos
    #

    if [[ -e "$HOME/Videos" ]] ; then
        mv "$HOME/"Videos/* "$( xdg-user-dir VIDEOS )/" 2>/dev/null || true

        rmdir "$HOME/Videos" 2>/dev/null 1>&2 || true

        # if still exist, move it somewhere that doesn't annoy us
        mv "$HOME/Videos" "$(xdg-user-dir VIDEOS )/" 2>/dev/null || true
    fi


    # FIX all the old references
    local entry conf dir file
    while read -ru 3 entry
    do
        if [[ "$entry" = .* ]] ; then
            entry="$HOME/$entry"

            # is a dir, scan all subfiles from it
            if [[ -d "$entry" ]] ; then
                while read -ru 3 file
                do
                    if grep -qsE "$HOME/(Images|Desktop|Downloads|Documents|Videos|Music)" "$file" ; then
                        migrate_conf_file "$file"
                    fi
                done 3<<< "$( find "$entry" -type f )"

            fi

            # is a file
            if [[ -f "$entry" ]] && [[ -s "$entry" ]] ; then
                if grep -qsE "$HOME/(Images|Desktop|Downloads|Documents|Videos|Music)" "$file" ; then
                    migrate_conf_file "$entry"
                fi
            fi
        fi
    done 3<<< "$( ls -a1 "$HOME" | awk 'NR > 2' )"



    # update again and save results
    xdg-user-dirs-update
    xdg-user-dirs-gtk-update

    # clean some files created by E17 which are useless:
    rm -f "$HOME/home.desktop" "$HOME/root.desktop" "$HOME/tmp.desktop"

    #
    # Publishare
    #

    # Make the publicshare folder to be directly shared
    # net usershare add NAME DIR COMMENT ACL GUEST
    net usershare add "${USER}_$( basename "$(xdg-user-dir PUBLICSHARE )" )" "$(xdg-user-dir PUBLICSHARE )" "$USER Public directory in $HOSTNAME computer" Everyone:r guest_ok=yes   #2>/dev/null 1>&2 || true


}

#
#  MAIN
#

# mv dir/* will include hidden files:
shopt -s dotglob

main "$@"

# put back values
shopt -u dotglob

# vim: set foldmethod=marker :
