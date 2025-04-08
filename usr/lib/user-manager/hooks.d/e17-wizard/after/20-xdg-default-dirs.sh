#!/bin/bash
SOURCE="$0"
source /usr/lib/elive-tools/functions
EL_REPORTS="1"
. gettext.sh
TEXTDOMAIN="elive-tools"
export TEXTDOMAIN

# if we are in e16, our updated (reconfigured) language must be updated, that's not needed in e17 since the ENV var is set
if [[ -n "$E_ROOT" ]] ; then
    source /etc/default/locale 2>/dev/null || true
fi

eliveversion="$( awk '$1 ~ /elive-version/ {($1="");print $0}' /etc/elive-version | sed 's/^\ //g' )"
cachedir="$HOME/.cache/elive-migration-to-${eliveversion}"


migrate_conf_file(){
    local file file_bkp
    file="$1"
    file_bkp="/tmp/.$(basename $0)-$USER-$(basename $file )"

    # debug info
    if [[ "$EL_DEBUG" -gt 2 ]] ; then
        if ((is_show_progress)) ; then
            echo "# cp \"$file\" \"$file_bkp\"" > "$TMP_PROGRESS_CONFIGURING_f"
        fi
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
    if [[ "${xdg_desktop}" != "$HOME/Desktop" ]] ; then
        if grep -Fqs "$HOME/Desktop" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Desktop|${xdg_download}|g" "$file"
            el_debug "Migrated references for __Desktop__ in __${file}__" 2>> "$cachedir/logs.txt"
            if ((is_show_progress)) ; then
                echo "# Migrated references for Desktop in ${file}" > "$TMP_PROGRESS_CONFIGURING_f"
            fi
        fi
    fi
    # downloads needs to be after desktop, since desktop was the real downloads dir
    if [[ "${xdg_download}" != "$HOME/Downloads" ]] ; then
        if grep -Fqs "$HOME/Downloads" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Downloads|${xdg_download}|g" "$file"
            el_debug "Migrated references for __Downloads__ in __${file}__" 2>> "$cachedir/logs.txt"
            if ((is_show_progress)) ; then
                echo "# Migrated references for Downloads in ${file}" > "$TMP_PROGRESS_CONFIGURING_f"
            fi
        fi
    fi

    if [[ "${xdg_documents}" != "$HOME/Documents" ]] ; then
        if grep -Fqs "$HOME/Documents" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Documents|${xdg_documents}|g" "$file"
            el_debug "Migrated references for __Documents__ in __${file}__" 2>> "$cachedir/logs.txt"
            if ((is_show_progress)) ; then
                echo "# Migrated references for Documents in ${file}" > "$TMP_PROGRESS_CONFIGURING_f"
            fi
        fi
    fi

    if [[ "${xdg_pictures}" != "$HOME/Images" ]] ; then
        if grep -Fqs "$HOME/Images" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Images|${xdg_pictures}|g" "$file"
            el_debug "Migrated references for __Images__ in __${file}__" 2>> "$cachedir/logs.txt"
            if ((is_show_progress)) ; then
                echo "# Migrated references for Images in ${file}" > "$TMP_PROGRESS_CONFIGURING_f"
            fi
        fi
    fi

    if [[ "${xdg_music}" != "$HOME/Music" ]] ; then
        if grep -Fqs "$HOME/Music" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Music|${xdg_music}|g" "$file"
            el_debug "Migrated references for __Music__ in __${file}__" 2>> "$cachedir/logs.txt"
            if ((is_show_progress)) ; then
                echo "# Migrated references for Music in ${file}" > "$TMP_PROGRESS_CONFIGURING_f"
            fi
        fi
    fi

    if [[ "${xdg_videos}" != "$HOME/Videos" ]] ; then
        if grep -Fqs "$HOME/Videos" "$file" 2>/dev/null ; then
            sed -i "s|$HOME/Videos|${xdg_videos}|g" "$file"
            el_debug "Migrated references for __Videos__ in __${file}__" 2>> "$cachedir/logs.txt"
            if ((is_show_progress)) ; then
                echo "# Migrated references for Videos in ${file}" > "$TMP_PROGRESS_CONFIGURING_f"
            fi
        fi
    fi


    # - replacements }}}

    # show debug to compare results
    if [[ "$EL_DEBUG" -gt 2 ]] ; then
        el_debug "Migrated conf file $file as:" 2>> "$cachedir/logs.txt"

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

    # debug mode
    if grep -Fqs "debug" /proc/cmdline ; then
        export EL_DEBUG=3
        if grep -Fqs "completedebug" /proc/cmdline ; then
            set -x
        fi
    fi


    if ! el_dependencies_check "xdg-user-dirs-update|xdg-user-dirs-gtk-update" ; then
        exit 1
    fi

    # }}}
    version="1.1"
    TMP_PROGRESS_CONFIGURING_f="/tmp/.$(basename $0)-${USER}-progress.txt"

    if [[ -z "${XDG_CONFIG_HOME}" ]] || [[ ! -d "$XDG_CONFIG_HOME" ]] ; then
        XDG_CONFIG_HOME="${HOME}/.config"
    fi

    if [[ -e "$HOME/.config/elive/migrator/xdg-default-dirs-language-upgraded.state" ]] && dpkg --compare-versions "$( cat "$HOME/.config/elive/migrator/xdg-default-dirs-language-upgraded.state" | tail -1 )" ge "$version" ; then
        el_debug "xdg home dirs already migrated to new language, version: $( cat "$HOME/.config/elive/migrator/xdg-default-dirs-language-upgraded.state" )"
        exit 0
    fi

    # show progress (after to request instmod)
    echo 1 > "$TMP_PROGRESS_CONFIGURING_f" > "$TMP_PROGRESS_CONFIGURING_f"

    # only show a gui if we are not in live mode!
    if ! grep -Fqs "boot=live" /proc/cmdline ; then
        is_show_progress=1
        { ( while test -f "$TMP_PROGRESS_CONFIGURING_f" ; do cat "$TMP_PROGRESS_CONFIGURING_f" || true ; sleep 1 ; done | $guitool --progress --pulsate --text="$( eval_gettext "Migrating directories and configurations to the selected language... This may take a while if you have many files. Please be patient." )" --auto-close ) & disown ; } 2>/dev/null
    fi


    # progress
    echo 10 > "$TMP_PROGRESS_CONFIGURING_f"

    # update language to the user's selected one first
    if [[ -n "$E_START" ]] ; then
        lang="$( enlightenment_remote -lang-get )"
        read -r lang <<< "$lang"

        if [[ -n "$lang" ]] ; then
            export LANG="$lang"
        fi
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

    # more info: https://wiki.archlinux.org/title/XDG_user_directories
    xdg_desktop="$( xdg-user-dir DESKTOP )"
    xdg_download="$( xdg-user-dir DOWNLOAD )"
    xdg_documents="$( xdg-user-dir DOCUMENTS )"
    xdg_pictures="$( xdg-user-dir PICTURES )"
    xdg_music="$( xdg-user-dir MUSIC )"
    xdg_videos="$( xdg-user-dir VIDEOS )"
    xdg_templates="$( xdg-user-dir TEMPLATES )"
    xdg_publicshare="$( xdg-user-dir PUBLICSHARE )"

    # source after to have created it and dirs
    # FIXME: what about future upgrades? do not remove it?
    source "${XDG_CONFIG_HOME}/user-dirs.dirs"
    cd

    #
    # Desktop & Downloads
    #

    # move old files to the new structure, if there was any
    if [[ "${xdg_download}" != "$HOME/Downloads" ]] ; then
        # if this is just a symlink (old deprecated dir), safe to remove like this
        rm -f "$HOME/Downloads" 2>/dev/null 1>&2 || true

        # and just in case is not a symlink:
        if [[ -e "$HOME/Downloads" ]] ; then
            if ((is_show_progress)) ; then
                echo "# Moving files in Downloads to ${xdg_download}" > "$TMP_PROGRESS_CONFIGURING_f"
            fi
            mv "$HOME/"Downloads/* "${xdg_download}/" 2>/dev/null || true

            rmdir "$HOME/Downloads" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            mv "$HOME/Downloads" "${xdg_download}/" 2>/dev/null || true
        fi
    fi


    desktop_translated_name="${xdg_desktop}"
    desktop_translated_name="${desktop_translated_name##*/}"

    # E already created the desktop dir and filled it with files (or maybe not files), we want to keep them so:
    mv "$HOME/$desktop_translated_name" "$HOME/desktop_old_d.tmp" 2>/dev/null || true

    # Create a better dir structure, we need this dir in any of the cases
    # XXX: note: we have already this structure thanks to our shipped xdg-default-dirs in /etc/xdg, nothing is wrong unless we change it
    desktop_d="$( basename "${xdg_download}")/$( basename "${xdg_desktop}" )"
    # create it, we need a real one, empty if possible, so that thunar don't hangs when creating new documents
    mkdir -p "$HOME/$desktop_d" "$XDG_CONFIG_HOME"

    # replace the desktop entry
    sed -i "s|^XDG_DESKTOP_DIR.*$|XDG_DESKTOP_DIR=\"\$HOME/$desktop_d\"|g" "${XDG_CONFIG_HOME}/user-dirs.dirs"

    # move back the files created by E to the new desktop dir
    mv "$HOME"/desktop_old_d.tmp/* "$HOME/$desktop_d/" 2>/dev/null || true
    rmdir "$HOME/desktop_old_d.tmp" 2>/dev/null || true


    if [[ "${xdg_desktop}" != "$HOME/Desktop" ]] ; then
        if [[ -e "$HOME/Desktop" ]] ; then

            if ((is_show_progress)) ; then
                echo "# Moving files in Desktop to ${xdg_desktop}" > "$TMP_PROGRESS_CONFIGURING_f"
            fi
            mv "$HOME/"Desktop/* "${xdg_desktop}/" 2>/dev/null || true

            rmdir "$HOME/Desktop" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            if [[ -e "$HOME/Desktop" ]] ; then
                mv "$HOME/Desktop" "${xdg_desktop}/"
            fi

        fi
    fi


    #
    # Templates
    #

    rmdir "${xdg_templates}" 2>/dev/null 1>&2 || true
    # Create a better dir structure, we need this dir in any of the cases
    templates_d="$( basename "${xdg_documents}")/$( basename "${xdg_templates}" )"
    # create it, we need a real one, empty if possible, so that thunar don't hangs when creating new documents
    mkdir -p "$HOME/$templates_d" "$XDG_CONFIG_HOME"

    # replace the templates entry
    sed -i "s|^XDG_TEMPLATES_DIR.*$|XDG_TEMPLATES_DIR=\"\$HOME/$templates_d\"|g" "${XDG_CONFIG_HOME}/user-dirs.dirs"


    # move old files to the new structure, if there was any
    if [[ "${xdg_templates}" != "$HOME/Templates" ]] ; then
        if [[ -e "$HOME/Templates" ]] ; then
            mv "$HOME/"Templates/* "${xdg_templates}/" 2>/dev/null || true

            rmdir "$HOME/Templates" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            mv "$HOME/Templates" "${xdg_templates}/" 2>/dev/null || true
        fi
    fi



    #
    # Documents
    #

    if [[ "${xdg_documents}" != "$HOME/Documents" ]] ; then
        if [[ -e "$HOME/Documents" ]] ; then
            if ((is_show_progress)) ; then
                echo "# Moving files in Documents to ${xdg_documents}" > "$TMP_PROGRESS_CONFIGURING_f"
            fi
            mv "$HOME/"Documents/* "${xdg_documents}/" 2>/dev/null || true

            rmdir "$HOME/Documents" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            mv "$HOME/Documents" "${xdg_documents}/" 2>/dev/null || true
        fi
    fi

    #
    # Music
    #

    if [[ "${xdg_music}" != "$HOME/Music" ]] ; then
        if [[ -e "$HOME/Music" ]] ; then
            if ((is_show_progress)) ; then
                echo "# Moving files in Music to ${xdg_music}" > "$TMP_PROGRESS_CONFIGURING_f"
            fi
            mv "$HOME/"Music/* "${xdg_music}/" 2>/dev/null || true

            rmdir "$HOME/Music" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            mv "$HOME/Music" "${xdg_music}/" 2>/dev/null || true
        fi
    fi

    #
    # Images / Pictures
    #

    if [[ "${xdg_pictures}" != "$HOME/Images" ]] ; then
        if [[ -e "$HOME/Images" ]] ; then
            if ((is_show_progress)) ; then
                echo "# Moving files in Images to ${xdg_pictures}" > "$TMP_PROGRESS_CONFIGURING_f"
            fi
            mv "$HOME/"Images/* "${xdg_pictures}/" 2>/dev/null || true

            rmdir "$HOME/Images" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            mv "$HOME/Images" "${xdg_pictures}/" 2>/dev/null || true
        fi
    fi

    #
    # Videos
    #

    if [[ "${xdg_videos}" != "$HOME/Videos" ]] ; then
        if [[ -e "$HOME/Videos" ]] ; then
            if ((is_show_progress)) ; then
                echo "# Moving files in Videos to ${xdg_videos}" > "$TMP_PROGRESS_CONFIGURING_f"
            fi
            mv "$HOME/"Videos/* "${xdg_videos}/" 2>/dev/null || true

            rmdir "$HOME/Videos" 2>/dev/null 1>&2 || true

            # if still exist, move it somewhere that doesn't annoy us
            mv "$HOME/Videos" "${xdg_videos}/" 2>/dev/null || true
        fi
    fi


    # FIX all the old references
    if [[ "${xdg_videos}" != "$HOME/Videos" ]] \
        && [[ "${xdg_music}" != "$HOME/Music" ]] \
        && [[ "${xdg_pictures}" != "$HOME/Images" ]] \
        && [[ "${xdg_documents}" != "$HOME/Documents" ]] \
        && [[ "${xdg_download}" != "$HOME/Downloads" ]] \
        && [[ "${xdg_desktop}" != "$HOME/Desktop" ]] \
        && [[ "${xdg_templates}" != "$HOME/Templates" ]] \
        ; then
        local entry conf dir file
        while read -ru 3 entry
        do
            if [[ "$entry" = .* ]] ; then
                entry="$HOME/$entry"

                # ignore these unneeded ones for speed reasons
                case "$entry" in
                    *".bin"|*".cfg"|*".vim"|*".db"|*".db-journal"|*".md"|*".markdown"|*".png"|*".Rakefile"|*".rb"|*".snippets"|*".svg"|*".txt"|*".xml"|*".yml"|*".gih"|*".gif"|*".vlt"|".gimp-"*|".kde"*|*".cargo"|*".cache"*|*"themes"|"e"|*".java"|*".smc"|*"config/GIMP"*|*".eet"*|*".edj"*|"readme"*|*".lock"*|*".lck"*|*"cookie"|*".tdb"|*"/cached/"*|*".sqlite"|*".py"|*".log"|*"history"*)
                        continue ; ;;
                esac

                # is a dir, scan all subfiles from it
                if [[ -d "$entry" ]] ; then

                    while read -ru 3 file
                    do
                        # ignore these unneeded ones for speed reasons
                        case "$file" in
                            *".bin"|*".cfg"|*".vim"|*".db"|*".db-journal"|*".md"|*".markdown"|*".png"|*".Rakefile"|*".rb"|*".snippets"|*".svg"|*".txt"|*".xml"|*".yml"|*".gih"|*".gif"|*".vlt"|".gimp-"*|".kde"*|*".cargo"|*".cache"*|*"themes"|"e"|*".java"|*".smc"|*"config/GIMP"*|*".eet"*|*".edj"*|"readme"*|*".lock"*|*".lck"*|*"cookie"|*".tdb"|*"/cached/"*|*".sqlite"|*".py"|*".log"|*"history"*)
                                continue ; ;;
                        esac

                        if grep -qsEa "$HOME/(Images|Desktop|Downloads|Documents|Videos|Music)" "$file" ; then
                            case "$(file -b "$file" )" in
                                *atabase*|*Image*|*image*|*audio*|*Audio*|*video*)
                                    # exclude these ones, unreliable
                                    true
                                    ;;
                                *text*|JSON*)
                                    migrate_conf_file "$file"
                                    ;;
                                data)
                                    if echo "$file" | grep -Fqs "config/transmission/" ; then
                                        migrate_conf_file "$file"
                                    else
                                        NOREPORTS=1 el_warning "Unknown filetype to migrate, continuing anyways for $(file -b "$file"): $file "
                                        migrate_conf_file "$file"
                                        echo "Unknown filetype $(file -b "$file" ) for: $file" >> "$cachedir/logs-unknown-filetypes.txt"
                                        is_migrate_files_done=1
                                    fi

                                    ;;
                                *)
                                    NOREPORTS=1 el_warning "Unknown filetype to migrate, continuing anyways for $(file -b "$file"): $file "
                                    migrate_conf_file "$file"
                                    # Only report if they are unknown filetypes, otherwise should be more than fine
                                    echo "Unknown filetype $(file -b "$file" ) for: $file" >> "$cachedir/logs-unknown-filetypes.txt"
                                    is_migrate_files_done=1
                                    ;;
                            esac
                        fi
                    done 3<<< "$( find "$entry" -type f | grep -viE "(\.cache/elive-migration|\.config/GIMP|\.png$|\.svg$)" )"
                fi

                # is a file
                if [[ -f "$entry" ]] && [[ -s "$entry" ]] ; then
                    if grep -qsE "$HOME/(Images|Desktop|Downloads|Documents|Videos|Music)" "$entry" ; then
                        case "$(file -b "$entry" )" in
                            *atabase*|*Image*|*image*|*audio*|*Audio*|*video*)
                                # exclude these ones, unreliable
                                true
                                ;;
                            *text*|JSON*)
                                migrate_conf_file "$entry"
                                ;;
                            data)
                                if echo "$entry" | grep -Fqs "config/transmission/" ; then
                                    migrate_conf_file "$entry"
                                else
                                    NOREPORTS=1 el_warning "Unknown filetype to migrate, continuing anyways for $(file -b "$entry"): $entry "
                                    migrate_conf_file "$entry"
                                    echo "Unknown filetype $(file -b "$entry" ) for: $entry" >> "$cachedir/logs-unknown-filetypes.txt"
                                    is_migrate_files_done=1
                                fi

                                ;;
                            *)
                                NOREPORTS=1 el_warning "Unknown filetype to migrate, continuing anyways for $(file -b "$entry"): $entry "
                                migrate_conf_file "$entry"
                                # Only report if they are unknown filetypes, otherwise should be more than fine
                                is_migrate_files_done=1
                                ;;
                        esac
                    fi
                fi
            fi
        #done 3<<< "$( ls -a1 "$HOME" | awk 'NR > 2' | grep -v "\.old$" )"
        done 3<<< "$( ls -a1 "$HOME" | grep -vE "(\.old$|^\.$|^\.\.$|\.cache|\.ccache|\.ecomp)" )"
    fi


    # explain how to verify results
    if ((is_migrate_files_done)) ; then
        local message_migrated_files
        message_migrated_files="$( printf "$( eval_gettext "Some configurations of your user have been migrated to the new directory names in your new language. Check changes by opening a terminal and running this command: %s" )" "cat $cachedir/logs.txt " )"

        zenity --info --text="$message_migrated_files" || true

        if LC_ALL=C dpkg --compare-versions "$eliveversion" "lt" "2.2.9" && el_check_version_development_is_days_recent 20 ; then
            local message_share_results
            message_share_results="$( printf "$( eval_gettext "Since you are testing a Beta version of Elive, we cannot guarantee that everything was migrated properly. Please help us improve the migration tools by sending the content of the file '%s' to Thanatermesis (via website). He will let you know if all is well. By submitting these details, you can contribute by reporting any possible errors." )" "$cachedir/logs-unknown-filetypes.txt" )"
            if zenity --question --text="$message_share_results" ; then
                hexchat &
                sleep 5
                zenity --info --text="Now, the easiest way is to open a terminal and run this command:  elivepaste ${cachedir}/logs-unknown-filetypes.txt" || true
            fi
        fi
    fi



    # update again and save results
    xdg-user-dirs-update
    xdg-user-dirs-gtk-update

    # more info: https://wiki.archlinux.org/title/XDG_user_directories
    xdg_desktop="$( xdg-user-dir DESKTOP )"
    xdg_download="$( xdg-user-dir DOWNLOAD )"
    xdg_documents="$( xdg-user-dir DOCUMENTS )"
    xdg_pictures="$( xdg-user-dir PICTURES )"
    xdg_music="$( xdg-user-dir MUSIC )"
    xdg_videos="$( xdg-user-dir VIDEOS )"
    xdg_templates="$( xdg-user-dir TEMPLATES )"
    xdg_publicshare="$( xdg-user-dir PUBLICSHARE )"

    # create symlinks for thunar panel
    rm -f "$HOME/.gtk-bookmarks"

    if ! grep -Fqs "file://$( xdg-user-dir DOCUMENTS | uri-gtk-encode )" "$HOME/.gtk-bookmarks" ; then
        echo -e "file://$( xdg-user-dir DOCUMENTS | uri-gtk-encode )" >> "$HOME/.gtk-bookmarks"
    fi
    if ! grep -Fqs "file://$( xdg-user-dir VIDEOS | uri-gtk-encode )" "$HOME/.gtk-bookmarks" ; then
        echo -e "file://$( xdg-user-dir VIDEOS | uri-gtk-encode )" >> "$HOME/.gtk-bookmarks"
    fi
    if ! grep -Fqs "file://$( xdg-user-dir DOWNLOAD | uri-gtk-encode )" "$HOME/.gtk-bookmarks" ; then
        echo -e "file://$( xdg-user-dir DOWNLOAD | uri-gtk-encode )" >> "$HOME/.gtk-bookmarks"
    fi
    if ! grep -Fqs "file:///tmp" "$HOME/.gtk-bookmarks" ; then
        echo -e "file:///tmp Temporal" >> "$HOME/.gtk-bookmarks"
    fi

    # compatibility for new location:
    mkdir -p "$HOME/.config/gtk-3.0"
    cp "$HOME/.gtk-bookmarks" "$HOME/.config/gtk-3.0/gtk-bookmarks"


    # clean some files created by E17 which are useless:
    # update: not needed anymore, we don't ship them with our e17 in any case
    #rm -f "$HOME/home.desktop" "$HOME/root.desktop" "$HOME/tmp.desktop"

    # mark a state flag so that we don't run this again
    # UPDATE: BUG FIXME: seems like if you switch between different languages, the directory contents are not migrated correctly (duplicated)
        # to fix this, better to do it after 3.0 & switching to version 1.2
    mkdir -p "$( dirname "$HOME/.config/elive/migrator/xdg-default-dirs-language-upgraded.state" )"
    echo "$version" > "$HOME/.config/elive/migrator/xdg-default-dirs-language-upgraded.state"

    # progress
    if ((is_show_progress)) ; then
        echo -e "# Done" > "$TMP_PROGRESS_CONFIGURING_f"
        sleep 1
    fi
    rm -f "$TMP_PROGRESS_CONFIGURING_f"

    # if we are debugging give it a little pause to see what is going on
    # if grep -Fqs "debug" /proc/cmdline ; then
    #     echo -e "debug: sleep 4" 1>&2
    #     sleep 4
    # fi


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
