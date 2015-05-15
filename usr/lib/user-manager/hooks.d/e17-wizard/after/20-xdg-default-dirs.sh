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
        echo "# cp \"$file\" \"$file_bkp\"" > "$TMP_PROGRESS_CONFIGURING_f"
        cp "$file" "$file_bkp"
    fi

    mkdir -p "$cachedir"

    # backup the file in case user wants to restore it:
    # update: bad idea, it takes a lot of space and nobody knows that really
    #cd "$cachedir"
    #echo "# Backuped $file to $cachedir" > "$TMP_PROGRESS_CONFIGURING_f"

    # backup to cachedir
    #if ! echo "$file" | grep -qsE "/\.(kde|cache|bkp)" ; then
        #echo "$file" | cpio -padu --quiet .
    #fi
    #cd


    # replacements {{{
    if [[ "$( xdg-user-dir DESKTOP )" != "$HOME/Desktop" ]] ; then
        if grep -qs "$HOME/Desktop" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Desktop|$( xdg-user-dir DOWNLOAD )|g" "$file"
            el_explain 0 "Migrated references for __Desktop__ in __${file}__" 2>> "$cachedir/logs.txt"
            echo "# Migrated references for Desktop in ${file}" > "$TMP_PROGRESS_CONFIGURING_f"
        fi
    fi
    # downloads needs to be after desktop, since desktop was the real downloads dir
    if [[ "$( xdg-user-dir DOWNLOAD )" != "$HOME/Downloads" ]] ; then
        if grep -qs "$HOME/Downloads" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Downloads|$( xdg-user-dir DOWNLOAD )|g" "$file"
            el_explain 0 "Migrated references for __Downloads__ in __${file}__" 2>> "$cachedir/logs.txt"
            echo "# Migrated references for Downloads in ${file}" > "$TMP_PROGRESS_CONFIGURING_f"
        fi
    fi

    if [[ "$( xdg-user-dir DOCUMENTS )" != "$HOME/Documents" ]] ; then
        if grep -qs "$HOME/Documents" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Documents|$( xdg-user-dir DOCUMENTS )|g" "$file"
            el_explain 0 "Migrated references for __Documents__ in __${file}__" 2>> "$cachedir/logs.txt"
            echo "# Migrated references for Documents in ${file}" > "$TMP_PROGRESS_CONFIGURING_f"
        fi
    fi

    if [[ "$( xdg-user-dir PICTURES )" != "$HOME/Images" ]] ; then
        if grep -qs "$HOME/Images" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Images|$( xdg-user-dir PICTURES )|g" "$file"
            el_explain 0 "Migrated references for __Images__ in __${file}__" 2>> "$cachedir/logs.txt"
            echo "# Migrated references for Images in ${file}" > "$TMP_PROGRESS_CONFIGURING_f"
        fi
    fi

    if [[ "$( xdg-user-dir MUSIC )" != "$HOME/Music" ]] ; then
        if grep -qs "$HOME/Music" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Music|$( xdg-user-dir MUSIC )|g" "$file"
            el_explain 0 "Migrated references for __Music__ in __${file}__" 2>> "$cachedir/logs.txt"
            echo "# Migrated references for Music in ${file}" > "$TMP_PROGRESS_CONFIGURING_f"
        fi
    fi

    if [[ "$( xdg-user-dir VIDEOS )" != "$HOME/Videos" ]] ; then
        if grep -qs "$HOME/Videos" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Videos|$( xdg-user-dir VIDEOS )|g" "$file"
            el_explain 0 "Migrated references for __Videos__ in __${file}__" 2>> "$cachedir/logs.txt"
            echo "# Migrated references for Videos in ${file}" > "$TMP_PROGRESS_CONFIGURING_f"
        fi
    fi


    # - replacements }}}

    # show debug to compare results
    if [[ "$EL_DEBUG" -gt 2 ]] ; then
        el_explain 0 "Migrated conf file $file as:" 2>> "$cachedir/logs.txt"

        if which colordiff 1>/dev/null 2>&1 ; then
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
    version="1.1"
    TMP_PROGRESS_CONFIGURING_f="/tmp/.$(basename $0)-${USER}-progress.txt"

    if [[ -z "${XDG_CONFIG_HOME}" ]] || [[ ! -d "$XDG_CONFIG_HOME" ]] ; then
        XDG_CONFIG_HOME="${HOME}/.config"
    fi

    if [[ -e "$HOME/.config/elive/migrator/xdg-default-dirs-language-upgraded.state" ]] ; then
        el_explain 0 "xdg home dirs already migrated to new language, version: $( cat "$HOME/.config/elive/migrator/xdg-default-dirs-language-upgraded.state" )"
        exit 0
    fi

    # show progress (after to request instmod)
    echo 1 > "$TMP_PROGRESS_CONFIGURING_f" > "$TMP_PROGRESS_CONFIGURING_f"

    { ( while test -f "$TMP_PROGRESS_CONFIGURING_f" ; do cat "$TMP_PROGRESS_CONFIGURING_f" || true ; sleep 1 ; done | $guitool --progress --pulsate --text="$( eval_gettext "Migrating directories and configurations to selected language, this operation can be very slow if you have much data, please be patient." )" --auto-close ) & disown ; } 2>/dev/null


    # progress
    echo 10 > "$TMP_PROGRESS_CONFIGURING_f" > "$TMP_PROGRESS_CONFIGURING_f"

    # update language to the user's selected one first
    lang="$( enlightenment_remote -lang-get )"
    # remove extra leading blank chars
    read -r lang <<< "$lang"
    if [[ -n "$lang" ]] ; then
        export LANG="$lang"
    else
        el_warning "unable to get lang conf by E remote"
    fi

    # clean conf, so create it again in case that already exists
    rm -f "${XDG_CONFIG_HOME}"/user-dirs.*

    #if [[ -s "${XDG_CONFIG_HOME}/user-dirs.dirs" ]] ; then
        #if $guitool --question --text="$( eval_gettext "Do you want to rename your default home directories like Music or Videos to the names used in your language?" )" ; then
            #rm -f "${XDG_CONFIG_HOME}"/user-dirs.*
        #else
            ## mark like we have upgraded
            #mkdir -p "$( dirname "$HOME/.config/elive/migrator/xdg-default-dirs-language-upgraded.state" )"
            #echo "$version" > "$HOME/.config/elive/migrator/xdg-default-dirs-language-upgraded.state"
            #rm -f "$TMP_PROGRESS_CONFIGURING_f"

            #exit
        #fi
    #fi

    # create dirs and default conf file
    xdg-user-dirs-update
    xdg-user-dirs-gtk-update

    # source after to have created it and dirs
    # FIXME: what about future upgrades? do not remove it?
    source "${XDG_CONFIG_HOME}/user-dirs.dirs"
    cd

    #
    # Desktop & Downloads
    #

    # move old files to the new structure, if there was any
    if [[ "$( xdg-user-dir DOWNLOAD )" != "$HOME/Downloads" ]] ; then
        # if this is just a symlink (old deprecated dir), safe to remove like this
        rm -f "$HOME/Downloads" 2>/dev/null 1>&2 || true

        # and just in case is not a symlink:
        if [[ -e "$HOME/Downloads" ]] ; then
            echo "# Moving files in Downloads to $( xdg-user-dir DOWNLOAD )" > "$TMP_PROGRESS_CONFIGURING_f"
            mv "$HOME/"Downloads/* "$( xdg-user-dir DOWNLOAD )/" 2>/dev/null || true

            rmdir "$HOME/Downloads" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            mv "$HOME/Downloads" "$(xdg-user-dir DOWNLOAD )/" 2>/dev/null || true
        fi
    fi


    desktop_translated_name="$( xdg-user-dir DESKTOP )"
    desktop_translated_name="${desktop_translated_name##*/}"

    # E already created the desktop dir and filled it with files (or maybe not files), we want to keep them so:
    mv "$HOME/$desktop_translated_name" "$HOME/desktop_old_d.tmp" 2>/dev/null || true

    # Create a better dir structure, we need this dir in any of the cases
    # XXX: note: we have already this structure thanks to our shipped xdg-default-dirs in /etc/xdg, nothing is wrong unless we change it
    desktop_d="$( basename "$(xdg-user-dir DOWNLOAD )")/$( basename "$(xdg-user-dir DESKTOP )" )"
    # create it, we need a real one, empty if possible, so that thunar don't hangs when creating new documents
    mkdir -p "$HOME/$desktop_d"

    # replace the desktop entry
    sed -i "s|^XDG_DESKTOP_DIR.*$|XDG_DESKTOP_DIR=\"\$HOME/$desktop_d\"|g" "${XDG_CONFIG_HOME}/user-dirs.dirs"

    # move back the files created by E to the new desktop dir
    mv "$HOME"/desktop_old_d.tmp/* "$HOME/$desktop_d/" 2>/dev/null || true
    rmdir "$HOME/desktop_old_d.tmp" 2>/dev/null || true


    if [[ "$( xdg-user-dir DESKTOP )" != "$HOME/Desktop" ]] ; then
        if [[ -e "$HOME/Desktop" ]] ; then

            echo "# Moving files in Desktop to $( xdg-user-dir DESKTOP )" > "$TMP_PROGRESS_CONFIGURING_f"
            mv "$HOME/"Desktop/* "$( xdg-user-dir DESKTOP )/" 2>/dev/null || true

            rmdir "$HOME/Desktop" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            if [[ -e "$HOME/Desktop" ]] ; then
                mv "$HOME/Desktop" "$(xdg-user-dir DESKTOP )/"
            fi

        fi
    fi


    #
    # Templates
    #

    rmdir "$(xdg-user-dir TEMPLATES )" 2>/dev/null 1>&2 || true
    # Create a better dir structure, we need this dir in any of the cases
    templates_d="$( basename "$(xdg-user-dir DOCUMENTS )")/$( basename "$(xdg-user-dir TEMPLATES )" )"
    # create it, we need a real one, empty if possible, so that thunar don't hangs when creating new documents
    mkdir -p "$HOME/$templates_d"

    # replace the templates entry
    sed -i "s|^XDG_TEMPLATES_DIR.*$|XDG_TEMPLATES_DIR=\"\$HOME/$templates_d\"|g" "${XDG_CONFIG_HOME}/user-dirs.dirs"


    # move old files to the new structure, if there was any
    if [[ "$( xdg-user-dir TEMPLATES )" != "$HOME/Templates" ]] ; then
        if [[ -e "$HOME/Templates" ]] ; then
            mv "$HOME/"Templates/* "$( xdg-user-dir TEMPLATES )/" 2>/dev/null || true

            rmdir "$HOME/Templates" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            mv "$HOME/Templates" "$(xdg-user-dir TEMPLATES )/" 2>/dev/null || true
        fi
    fi



    #
    # Documents
    #

    if [[ "$( xdg-user-dir DOCUMENTS )" != "$HOME/Documents" ]] ; then
        if [[ -e "$HOME/Documents" ]] ; then
            echo "# Moving files in Documents to $( xdg-user-dir DOCUMENTS )" > "$TMP_PROGRESS_CONFIGURING_f"
            mv "$HOME/"Documents/* "$( xdg-user-dir DOCUMENTS )/" 2>/dev/null || true

            rmdir "$HOME/Documents" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            mv "$HOME/Documents" "$(xdg-user-dir DOCUMENTS )/" 2>/dev/null || true
        fi
    fi

    #
    # Music
    #

    if [[ "$( xdg-user-dir MUSIC )" != "$HOME/Music" ]] ; then
        if [[ -e "$HOME/Music" ]] ; then
            echo "# Moving files in Music to $( xdg-user-dir MUSIC )" > "$TMP_PROGRESS_CONFIGURING_f"
            mv "$HOME/"Music/* "$( xdg-user-dir MUSIC )/" 2>/dev/null || true

            rmdir "$HOME/Music" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            mv "$HOME/Music" "$(xdg-user-dir MUSIC )/" 2>/dev/null || true
        fi
    fi

    #
    # Images / Pictures
    #

    if [[ "$( xdg-user-dir PICTURES )" != "$HOME/Images" ]] ; then
        if [[ -e "$HOME/Images" ]] ; then
            echo "# Moving files in Images to $( xdg-user-dir PICTURES )" > "$TMP_PROGRESS_CONFIGURING_f"
            mv "$HOME/"Images/* "$( xdg-user-dir PICTURES )/" 2>/dev/null || true

            rmdir "$HOME/Images" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            mv "$HOME/Images" "$(xdg-user-dir PICTURES )/" 2>/dev/null || true
        fi
    fi

    #
    # Videos
    #

    if [[ "$( xdg-user-dir VIDEOS )" != "$HOME/Videos" ]] ; then
        if [[ -e "$HOME/Videos" ]] ; then
            echo "# Moving files in Videos to $( xdg-user-dir VIDEOS )" > "$TMP_PROGRESS_CONFIGURING_f"
            mv "$HOME/"Videos/* "$( xdg-user-dir VIDEOS )/" 2>/dev/null || true

            rmdir "$HOME/Videos" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            mv "$HOME/Videos" "$(xdg-user-dir VIDEOS )/" 2>/dev/null || true
        fi
    fi


    # FIX all the old references
    if [[ "$( xdg-user-dir VIDEOS )" != "$HOME/Videos" ]] \
        && [[ "$( xdg-user-dir MUSIC )" != "$HOME/Music" ]] \
        && [[ "$( xdg-user-dir PICTURES )" != "$HOME/Images" ]] \
        && [[ "$( xdg-user-dir DOCUMENTS )" != "$HOME/Documents" ]] \
        && [[ "$( xdg-user-dir DOWNLOAD )" != "$HOME/Downloads" ]] \
        && [[ "$( xdg-user-dir DESKTOP )" != "$HOME/Desktop" ]] \
        && [[ "$( xdg-user-dir VIDEOS )" != "$HOME/Templates" ]] \
        ; then
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
                    done 3<<< "$( find "$entry" -type f | grep -v "$cachedir" )"

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

    # create symlinks for thunar panel
    if ! grep -qs "file://$( xdg-user-dir DOWNLOAD )" "$HOME/.gtk-bookmarks" ; then
        echo -e "file://$( xdg-user-dir DOWNLOAD )" >> "$HOME/.gtk-bookmarks"
    fi
    #if ! grep -qs "file://$( xdg-user-dir DOCUMENTS )" "$HOME/.gtk-bookmarks" ; then
        #echo -e "file://$( xdg-user-dir DOCUMENTS )" >> "$HOME/.gtk-bookmarks"
    #fi
    #if ! grep -qs "file://$( xdg-user-dir VIDEOS )" "$HOME/.gtk-bookmarks" ; then
        #echo -e "file://$( xdg-user-dir VIDEOS )" >> "$HOME/.gtk-bookmarks"
    #fi
    #if ! grep -qs "file://$( xdg-user-dir MUSIC )" "$HOME/.gtk-bookmarks" ; then
        #echo -e "file://$( xdg-user-dir MUSIC )" >> "$HOME/.gtk-bookmarks"
    #fi
    if ! grep -qs "file:///tmp" "$HOME/.gtk-bookmarks" ; then
        echo -e "file:///tmp Temporal" >> "$HOME/.gtk-bookmarks"
    fi

    # compatibility for new location:
    mkdir -p "$HOME/.config/gtk-3.0"
    cp "$HOME/.gtk-bookmarks" "$HOME/.config/gtk-3.0/gtk-bookmarks"


    # clean some files created by E17 which are useless:
    # update: not needed anymore, we don't ship them with our e17 in any case
    #rm -f "$HOME/home.desktop" "$HOME/root.desktop" "$HOME/tmp.desktop"

    #
    # Public Share
    #

    # Make the publicshare folder to be directly shared
    # net usershare add NAME DIR COMMENT ACL GUEST
    net usershare add "${USER}_$( basename "$(xdg-user-dir PUBLICSHARE )" )" "$(xdg-user-dir PUBLICSHARE )" "$USER Public directory in $HOSTNAME computer" Everyone:r guest_ok=yes   2>/dev/null 1>&2 || true

    # mark a state flag so that we don't run this again
    mkdir -p "$( dirname "$HOME/.config/elive/migrator/xdg-default-dirs-language-upgraded.state" )"
    echo "$version" > "$HOME/.config/elive/migrator/xdg-default-dirs-language-upgraded.state"

    # progress
    echo -e "# Done" > "$TMP_PROGRESS_CONFIGURING_f"
    sleep 1
    rm -f "$TMP_PROGRESS_CONFIGURING_f"

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
