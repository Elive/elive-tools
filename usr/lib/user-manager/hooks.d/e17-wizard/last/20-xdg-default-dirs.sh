#!/bin/bash
source /usr/lib/elive-tools/functions
. gettext.sh
TEXTDOMAIN="elive-tools"
export TEXTDOMAIN

eliveversion="$( awk '$1 ~ /elive-version/ {($1="");print $0}' /etc/elive-version | sed 's/^\ //g' )"
cachedir="$HOME/.cache/elive-migration-to-${eliveversion}"

migrate_conf_file(){
    local file file_bkp
    file="$1"
    file_bkp="/tmp/.$(basename $0)-$USER-$(basename $file )"

    # debug info
    if [[ "$EL_DEBUG" -gt 2 ]] ; then
        cp "$file" "$file_bkp"
    fi

    # backup the file in case user wants to restore it:
    mkdir -p "$cachedir"
    cd "$cachedir"
    echo "$file" | cpio -paduv .
    cd


    # replacements {{{
    if [[ "$( xdg-user-dir DESKTOP )" != */Desktop ]] ; then
        if grep -qs "$HOME/Desktop" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Desktop|$( xdg-user-dir DOWNLOAD )|g" "$file"
            el_explain 0 "Migrated references for __Desktop__ in __${file}__" 2>> "$cachedir/logs.txt"
        fi
    fi
    # downloads needs to be after desktop, since desktop was the real downloads dir
    if [[ "$( xdg-user-dir DOWNLOAD )" != */Downloads ]] ; then
        if grep -qs "$HOME/Downloads" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Downloads|$( xdg-user-dir DOWNLOAD )|g" "$file"
            el_explain 0 "Migrated references for __Downloads__ in __${file}__" 2>> "$cachedir/logs.txt"
        fi
    fi

    if [[ "$( xdg-user-dir DOCUMENTS )" != */Documents ]] ; then
        if grep -qs "$HOME/Documents" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Documents|$( xdg-user-dir DOCUMENTS )|g" "$file"
            el_explain 0 "Migrated references for __Documents__ in __${file}__" 2>> "$cachedir/logs.txt"
        fi
    fi

    if [[ "$( xdg-user-dir PICTURES )" != */Images ]] ; then
        if grep -qs "$HOME/Images" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Images|$( xdg-user-dir PICTURES )|g" "$file"
            el_explain 0 "Migrated references for __Images__ in __${file}__" 2>> "$cachedir/logs.txt"
        fi
    fi

    if [[ "$( xdg-user-dir MUSIC )" != */Music ]] ; then
        if grep -qs "$HOME/Music" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Music|$( xdg-user-dir MUSIC )|g" "$file"
            el_explain 0 "Migrated references for __Music__ in __${file}__" 2>> "$cachedir/logs.txt"
        fi
    fi

    if [[ "$( xdg-user-dir VIDEOS )" != */Videos ]] ; then
        if grep -qs "$HOME/Videos" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Videos|$( xdg-user-dir VIDEOS )|g" "$file"
            el_explain 0 "Migrated references for __Videos__ in __${file}__" 2>> "$cachedir/logs.txt"
        fi
    fi


    # - replacements }}}

    # show debug to compare results
    if [[ "$EL_DEBUG" -gt 2 ]] ; then
        el_explain 0 "Migrated conf file $file as:" 2>> "$cachedir/logs.txt"

        if [[ -x "$(which colordiff)" ]] ; then
            diff "$file_bkp" "$file" | colordiff >> "$cachedir/logs.txt"
        else
            diff "$file_bkp" "$file" >> "$cachedir/logs.txt"
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
    rm -f "$(xdg-user-dir DESKTOP )/home.desktop" 2>/dev/null 1>&2 || true
    rm -f "$(xdg-user-dir DESKTOP )/root.desktop" 2>/dev/null 1>&2 || true
    rm -f "$(xdg-user-dir DESKTOP )/tmp.desktop" 2>/dev/null 1>&2 || true
    rm -f "$(xdg-user-dir DOWNLOAD )/home.desktop" 2>/dev/null 1>&2 || true
    rm -f "$(xdg-user-dir DOWNLOAD )/root.desktop" 2>/dev/null 1>&2 || true
    rm -f "$(xdg-user-dir DOWNLOAD )/tmp.desktop" 2>/dev/null 1>&2 || true


    rmdir "$(xdg-user-dir DESKTOP )" 2>/dev/null 1>&2 || true

    # and never create it again
    sed -i "/^XDG_DESKTOP_DIR/d" "${XDG_CONFIG_HOME}/user-dirs.dirs"
    #echo -e "XDG_DESKTOP_DIR=\"\$HOME/\"" >> "${XDG_CONFIG_HOME}/user-dirs.dirs"
    # put it on the same place as downloads, not main homedir
    grep "^XDG_DOWNLOAD_DIR=" "${XDG_CONFIG_HOME}/user-dirs.dirs" | sed -e 's|_DOWNLOAD_|_DESKTOP_|g' >> "${XDG_CONFIG_HOME}/user-dirs.dirs"


    #
    # Templates
    #

    # delete if empty
    rmdir "$(xdg-user-dir TEMPLATES )" 2>/dev/null 1>&2 || true
    templates_d="$( basename "$(xdg-user-dir DOCUMENTS )")/$( basename "$(xdg-user-dir TEMPLATES )" )"
    # create it, we need a real one, empty if possible, so that thunar don't hangs when creating new documents
    mkdir -p "$HOME/$templates_d"

    # replace the templates entry
    sed -i "s|^XDG_TEMPLATES_DIR.*$|XDG_TEMPLATES_DIR=\"\$HOME/$templates_d\"|g" "${XDG_CONFIG_HOME}/user-dirs.dirs"


    #
    # Documents
    #

    if [[ "$( xdg-user-dir DOCUMENTS )" != */Documents ]] ; then
        if [[ -e "$HOME/Documents" ]] ; then
            mv "$HOME/"Documents/* "$( xdg-user-dir DOCUMENTS )/" 2>/dev/null || true

            rmdir "$HOME/Documents" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            mv "$HOME/Documents" "$(xdg-user-dir DOCUMENTS )/" 2>/dev/null || true
        fi
    fi

    #
    # Music
    #

    if [[ "$( xdg-user-dir MUSIC )" != */Music ]] ; then
        if [[ -e "$HOME/Music" ]] ; then
            mv "$HOME/"Music/* "$( xdg-user-dir MUSIC )/" 2>/dev/null || true

            rmdir "$HOME/Music" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            mv "$HOME/Music" "$(xdg-user-dir MUSIC )/" 2>/dev/null || true
        fi
    fi

    #
    # Images / Pictures
    #

    if [[ "$( xdg-user-dir PICTURES )" != */Images ]] ; then
        if [[ -e "$HOME/Images" ]] ; then
            mv "$HOME/"Images/* "$( xdg-user-dir PICTURES )/" 2>/dev/null || true

            rmdir "$HOME/Images" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            mv "$HOME/Images" "$(xdg-user-dir PICTURES )/" 2>/dev/null || true
        fi
    fi

    #
    # Videos
    #

    if [[ "$( xdg-user-dir VIDEOS )" != */Videos ]] ; then
        if [[ -e "$HOME/Videos" ]] ; then
            mv "$HOME/"Videos/* "$( xdg-user-dir VIDEOS )/" 2>/dev/null || true

            rmdir "$HOME/Videos" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            mv "$HOME/Videos" "$(xdg-user-dir VIDEOS )/" 2>/dev/null || true
        fi
    fi


    # FIX all the old references
    if [[ "$( xdg-user-dir VIDEOS )" != */Videos ]] && [[ "$( xdg-user-dir MUSIC )" != */Music ]] && [[ "$( xdg-user-dir PICTURES )" != */Images ]] && [[ "$( xdg-user-dir DOCUMENTS )" != */Documents ]] && [[ "$( xdg-user-dir DOWNLOAD )" != */Downloads ]] && [[ "$( xdg-user-dir DESKTOP )" != */Desktop ]] ; then
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
                            case "$(file -b "$file" )" in
                                *atabase*|*Image*|*image*|*audio*|*Audio*|*video*)
                                    # exclude these ones, unreliable
                                    true
                                    ;;
                                *text*)
                                    migrate_conf_file "$file"
                                    ;;
                                data)
                                    if echo "$file" | grep -qs "config/transmission/" ; then
                                        migrate_conf_file "$file"
                                    else
                                        el_warning "Unkown filetype to migrate, continuing anyways for $(file -b "$file"): $file "
                                        migrate_conf_file "$file"
                                        echo "Unknown filetype $(file -b "$file" ) for: $file" >> "$cachedir/logs-unknown-filetypes.txt"
                                        is_migrate_files_done=1
                                    fi

                                    ;;
                                *)
                                    el_warning "Unkown filetype to migrate, continuing anyways for $(file -b "$file"): $file "
                                    migrate_conf_file "$file"
                                    # Only report if they are unknown filetypes, otherwise should be more than fine
                                    echo "Unknown filetype $(file -b "$file" ) for: $file" >> "$cachedir/logs-unknown-filetypes.txt"
                                    is_migrate_files_done=1
                                    ;;
                            esac
                        fi
                    done 3<<< "$( find "$entry" -type f )"

                fi

                # is a file
                if [[ -f "$entry" ]] && [[ -s "$entry" ]] ; then
                    if grep -qsE "$HOME/(Images|Desktop|Downloads|Documents|Videos|Music)" "$file" ; then
                        case "$(file -b "$file" )" in
                            *atabase*|*Image*|*image*|*audio*|*Audio*|*video*)
                                # exclude these ones, unreliable
                                true
                                ;;
                            *text*)
                                migrate_conf_file "$file"
                                ;;
                            *)
                                el_warning "Unkown filetype to migrate, continuing anyways for $(file -b "$file"): $file "
                                migrate_conf_file "$file"
                                # Only report if they are unknown filetypes, otherwise should be more than fine
                                is_migrate_files_done=1
                                ;;
                        esac
                    fi
                fi
            fi
        done 3<<< "$( ls -a1 "$HOME" | awk 'NR > 2' | grep -v "\.old$" )"
    fi


    # explain how to verify results
    if ((is_migrate_files_done)) ; then
        local message_migrated_files
        message_migrated_files="$( printf "$( eval_gettext "Some configurations in your home has been migrated to the new directory names that are now set in your own language, you can see what exactly has changed by opening a terminal and running this command: %s" )" "cat $cachedir/logs.txt " )"

        zenity --info --text="$message_migrated_files"

        if LC_ALL=C dpkg --compare-versions "$eliveversion" "lt" "2.2.9" && el_check_version_development_is_days_recent 20 ; then
            local message_share_results
            message_share_results="$( printf "$( eval_gettext "Since your beta version of elive is very recent, we cannot guarantee you that everything was migrated fine, please help us to improve the migration tools by open the chat application and show to Thanatermesis the contents of this file: '%s' and he will tell you if all looks good, also, you are contributing in reporting any possible error and he will tell you how to restore any file if you need to." )" "$cachedir/logs-unknown-filetypes.txt" )"
            if zenity --question --text="$message_share_results" ; then
                xchat &
                sleep 5
                zenity --info --text="Now, the easiest way is to open a terminal and run this command:  elivepaste ${cachedir}/logs-unknown-filetypes.txt"
            fi
        fi
    fi



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

    # if we are debugging give it a little pause to see what is going on
    if grep -qs "debug" /proc/cmdline ; then
        echo -e "debug: sleep 4" 1>&2
        sleep 4
    fi


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
