#!/bin/bash
SOURCE="$0"
source /usr/lib/elive-tools/functions
EL_REPORTS="1"
el_make_environment
. gettext.sh
TEXTDOMAIN="elive-tools"
export TEXTDOMAIN

# if we are in e16, our updated (reconfigured) language must be updated, that's not needed in e17 since the ENV var is set
if [[ -n "$E_ROOT" ]] ; then
    source /etc/default/locale 2>/dev/null || true
fi


main(){
    # pre {{{
    local file menu menu_auto menu_auto_live message_gui buf

    RAM_TOTAL_SIZE_bytes="$(grep MemTotal /proc/meminfo | tr ' ' '\n' | grep "^[[:digit:]]*[[:digit:]]$" | head -1 )"
    RAM_TOTAL_SIZE_mb="$(( $RAM_TOTAL_SIZE_bytes / 1024 ))"
    RAM_TOTAL_SIZE_mb="${RAM_TOTAL_SIZE_mb%.*}"

    if grep -qs "boot=live" /proc/cmdline ; then
        is_live=1
    else
        if ! el_dependencies_check "zenity" ; then
            exit
        fi
    fi

    # }}}

    if [[ -n "$EROOT" ]] ; then
        # e16
        order_file="$HOME/.e16/startup-applications.list"
    else
        if [[ -x "$(which enlightenment)" ]] ; then
            E_VERSION="$( enlightenment --version | grep "^Version: " | sed -e 's|^Version: ||g' | tail -1 )"
            case "$E_VERSION" in
                0.17.*)
                    order_file="$HOME/.e/e17/applications/startup/.order"
                    ;;
                *)
                    el_error "unknown version of Enlightenment, ignoring selection of startup applications: '$E_VERSION' "
                    exit
                    ;;
            esac
        fi
    fi

    # create a default dir
    mkdir -p "$(dirname "$order_file" )"
    touch "$order_file"
    mkdir -p "$HOME/.config/autostart"

    while read -ru 3 file
    do
        unset name comment
        #echo "$file"

        # checks {{{
        if [[ ! -s "$file" ]] ; then
            continue
        fi

        filename="$(basename "$file" )"

        # - checks }}}
        # un-needed / blacklisted ones {{{
        if [[ -n "$EROOT" ]] ; then
            # E16 requires different ones
            if echo "$filename" | LC_ALL=C grep -qsEi "^(kde|glipper-|print-applet|notification-daemon|user-dirs-update-gtk|elive-support-donations|org.gnome.SettingsDaemon|gnome-software-service|tracker-store)" ; then
                # glipper: we want to enable it in a different way: if ctrl+alt+c si pressed, run it for 8 hours long and close/kill it to save mem
                # nm-applet: already integrated in elive correctly and saving mem
                #       e16 doesn't has a module or anything so keep it running from the trayer
                # wicd-: deprecated and not needed for elive
                # print-applet: useless
                # notification-daemon: dont include it if we are going to use e17's one
                # user-dirs-update-gtk: we dont want to run the "directories renamer", becuase: 1) it doesnt move files to the new dirs, 2) its async and can conflict with our renamer, 3) our renamer (e17 restart conf hooks) already does it, it mess up and fucks the users! they should be NEVER renamed after the system is set up, no matter what! even scripts can point to them not-dynamically
                # elive-support-donations: this is simply annoying to have, even monthly showing (lol), but since we have upgrades with changelogs asking for possible donations that does the same (better) job, so disable this one by default
                continue
            fi

        else
            # E17 / E22
            if echo "$filename" | LC_ALL=C grep -qsEi "^(kde|glipper-|nm-applet|wicd-|print-applet|notification-daemon|user-dirs-update-gtk|elive-support-donations|org.gnome.SettingsDaemon|gnome-software-service|tracker-store)" ; then
                # glipper: we want to enable it in a different way: if ctrl+alt+c si pressed, run it for 8 hours long and close/kill it to save mem
                # nm-applet: already integrated in elive correctly and saving mem
                # wicd-: deprecated and not needed for elive
                # print-applet: useless
                # notification-daemon: dont include it if we are going to use e17's one
                # user-dirs-update-gtk: we dont want to run the "directories renamer", becuase: 1) it doesnt move files to the new dirs, 2) its async and can conflict with our renamer, 3) our renamer (e17 restart conf hooks) already does it, it mess up and fucks the users! they should be NEVER renamed after the system is set up, no matter what! even scripts can point to them not-dynamically
                # elive-support-donations: this is simply annoying to have, even monthly showing (lol), but since we have upgrades with changelogs asking for possible donations that does the same (better) job, so disable this one by default
                continue
            fi
        fi
        # e16 cases
        if [[ -n "$EROOT" ]] ; then
            if echo "$filename" | LC_ALL=C grep -qsEi "^(pulseaudio)" ; then
                # pulseaudio*: starte16 already starts it, and its needed to start it before the desktop starts otherwise we could have an error in desktop
                # update: not sure if this is needed anymore (and remove from starte16)
                continue
            fi
        fi
        # - un-needed ones }}}
        # default to enabled/disabled {{{

        case "$filename" in
            # do we need a touch-screen keyboard?
            "onboard-autostart.desktop")
                if grep -qs "keyboard: not found" /etc/elive-version ; then
                    menu+=("TRUE")
                    menu_auto+=("$file")
                    menu_auto_live+=("$file")
                    el_debug "state: TRUE"
                else
                    menu+=("FALSE")
                    el_debug "state: FALSE"
                fi
                ;;
            "blueman.desktop")
                # make sure we have bluetooth device
                if hcitool dev | grep -qs ":.*:.*:" ; then
                    if [[ -n "$EROOT" ]] ; then
                        menu+=("TRUE")
                        menu_auto+=("$file")
                        menu_auto_live+=("$file")
                        el_debug "state: TRUE"
                    else
                        menu+=("FALSE")
                        el_debug "state: FALSE"
                    fi
                else
                    menu+=("FALSE")
                    el_debug "state: FALSE"
                fi
                ;;

            *)
                if [[ "$RAM_TOTAL_SIZE_mb" -gt 900 ]] ; then
                    # E16 requires different ones
                    if [[ -n "$EROOT" ]] ; then
                        if echo "$filename" | LC_ALL=C grep -qsEi "^(polkit|gdu-notif|gnome-keyring|user-dirs-update|update-notifier|pulseaudio|elive-)" ; then
                            menu+=("TRUE")
                            menu_auto+=("$file")
                            el_debug "state: TRUE"
                        else
                            menu+=("FALSE")
                            el_debug "state: FALSE"
                        fi
                    else
                        if echo "$filename" | LC_ALL=C grep -qsEi "^(polkit|gdu-notif|gnome-keyring|user-dirs-update|update-notifier|pulseaudio|elive-)" ; then
                            menu+=("TRUE")
                            menu_auto+=("$file")
                            el_debug "state: TRUE"
                        else
                            menu+=("FALSE")
                            el_debug "state: FALSE"
                        fi
                    fi
                else
                    if echo "$filename" | LC_ALL=C grep -qsEi "^(polkit|gdu-notif|user-dirs-update|pulseaudio|elive-)" ; then
                        menu+=("TRUE")
                        menu_auto+=("$file")
                        el_debug "state: TRUE"
                    else
                        menu+=("FALSE")
                        el_debug "state: FALSE"
                    fi
                fi
                ;;
        esac


        # auto menu for live mode
        if [[ -n "$EROOT" ]] ; then
            if echo "$filename" | LC_ALL=C grep -qsEi "^(polkit|elive-|gnome-keyring|pulseaudio)" ; then
                menu_auto_live+=("$file")
            fi
        else
            if echo "$filename" | LC_ALL=C grep -qsEi "^(polkit|elive-|gnome-keyring|pulseaudio)" ; then
                menu_auto_live+=("$file")
            fi
        fi
        # - default to enabled/disabled }}}

        # include file
        menu+=("$file")
        el_debug "file: $file"

        # include name {{{
        if [[ "${LANG%%.*}" = "en_US" ]] ; then
            name="$( LC_ALL=C grep "^Name=" "$file" | psort -- -p "_" -p "@" | head -1 )"
        fi
        if [[ -z "$name" ]] ; then
            name="$( grep "^Name\[${LANG%%.*}\]" "$file" | psort -- -p "_" -p "@" | head -1 )"
            if [[ -z "$name" ]] ; then
                name="$( grep "^Name\[${LANG%%.*}" "$file" | psort -- -p "_" -p "@" | head -1 )"
                if [[ -z "$name" ]] ; then
                    name="$( grep "^Name\[${LANG%%_*}\]" "$file" | psort -- -p "_" -p "@" | head -1 )"
                    if [[ -z "$name" ]] ; then
                        name="$( grep "^Name\[${LANG%%_*}" "$file" | psort -- -p "_" -p "@" | head -1 )"
                        if [[ -z "$name" ]] ; then
                            name="$( grep "^Name=" "$file" | psort -- -p "_" -p "@" | head -1 )"
                            if [[ -z "$name" ]] ; then
                                name="$( basename "${file%.*}" )"
                            fi
                        fi
                    fi
                fi
            fi
        fi

        # empty?
        if [[ -z "$name" ]] ; then
            name="(empty)"
        fi
        # add name
        name="${name#*]=}"
        name="${name#Name=}"
        menu+=("${name}")
        el_debug "name: ${name}"

        # }}}
        # include comment {{{
        if [[ "${LANG%%.*}" = "en_US" ]] ; then
            comment="$( LC_ALL=C grep "^Comment=" "$file" | psort -- -p "_" -p "@" | head -1 )"
        fi
        if [[ -z "$comment" ]] ; then
            comment="$( grep "^Comment\[${LANG%%.*}\]" "$file" | psort -- -p "_" -p "@" | head -1 )"
            if [[ -z "$comment" ]] ; then
                comment="$( grep "^Comment\[${LANG%%.*}" "$file" | psort -- -p "_" -p "@" | head -1 )"
                if [[ -z "$comment" ]] ; then
                    comment="$( grep "^Comment\[${LANG%%_*}\]" "$file" | psort -- -p "_" -p "@" | head -1 )"
                    if [[ -z "$comment" ]] ; then
                        comment="$( grep "^Comment=" "$file" | psort -- -p "_" -p "@" | head -1 )"
                        if [[ -z "$comment" ]] ; then
                            comment="$( grep "^Comment\[${LANG%%_*}" "$file" | psort -- -p "_" -p "@" | head -1 )"
                        fi
                    fi
                fi
            fi
        fi

        # empty?
        if [[ -z "$comment" ]] ; then
            comment="(empty)"
        fi
        comment="${comment#*]=}"
        comment="${comment#Comment=}"
        # add comment
        menu+=("${comment}")
        el_debug "comment: ${comment}"

        el_debug "       (loop)"
        # }}}

    done 3<<< "$( find /etc/xdg/autostart/ "$HOME/.config/autostart/" -type f -iname '*'.desktop | sort -u )"


    if [[ "$RAM_TOTAL_SIZE_mb" -lt 700 ]] ; then
        message_gui="$( printf "$( eval_gettext "Select the services that you want to have enabled for your desktop. Note that you don't have much RAM memory and services will use it. Elive has already pre-selected the best options for you." )" )"
    else
        message_gui="$( printf "$( eval_gettext "Select the services that you want to have enabled on your desktop. Elive has already pre-selected the best options for you." )" )"
    fi

    # live (auto) mode?
    if ((is_live)) ; then
        unset answer
        # create result variable
        for line in "${menu_auto_live[@]}"
        do
            answer="${line}|${answer%|}"
        done

    else

        # needed to make sure that the gui is launched?
        #timeout 1 zenity --info 2>/dev/null || true
        # interactive mode, default
        # include a timeout to make sure that if is not displayed, is closed
        answer="$( timeout 1200 zenity --list --checklist --height=580 --width=630 --text="$message_gui"  --column="" --column="" --column="$( eval_gettext "Name" )" --column="$( eval_gettext "Comment" )" "${menu[@]}" --print-column=2 --hide-column=2 || echo cancel )"

        # use defaults if failed or canceled
        if [[ -z "$answer" ]] || [[ "$answer" = "cancel" ]] ; then
            unset answer
            for line in "${menu_auto[@]}"
            do
                answer="${line}|${answer%|}"
            done
        fi
    fi

    # include the legacy elxstrt always
    if [[ -r "$HOME/.local/share/applications/elxstrt.desktop" ]] ; then
        if ! LC_ALL=C grep -qs "elxstrt.desktop" "${order_file}" ; then
            echo "$HOME/.local/share/applications/elxstrt.desktop" >> "${order_file}"
        fi
    fi


    while read -ru 3 file
    do
        if [[ -s "$file" ]] ; then
            filename="$(basename "$file" )"

            # verify the needed ones
            if [[ "$filename" = polkit*authentication* ]] ; then
                is_polkit_auth_included=1
            fi

            if [[ "$filename" = gdu*notifica* ]] ; then
                is_gdu_notif_included=1
            fi

            if ! LC_ALL=C grep -qs "^${file}$" "${order_file}" ; then
                echo "$file" >> "${order_file}"
            fi
        fi
    done 3<<< "$( echo "$answer" | tr '|' '\n' )"

    # polkit auth

    if ! ((is_live)) ; then
        if ! ((is_polkit_auth_included)) ; then
            if ls /etc/xdg/autostart/polkit-*authentication*desktop 1>/dev/null 2>/dev/null ; then
                if zenity --question --text="$( eval_gettext "You have not included Polkit authentication agent which is needed for correct system functionality, it allows you to use media devices or mount hard disks. However, Elive can add a special configuration that allows you to still use the disks. Are you sure that you want to disable it?" )" ; then
                    is_polkit_auth_disabled_wanted=1
                else
                    # re-enable it
                    file="$( echo "$answer" | tr '|' '\n' | grep "/polkit.*authentication" | head -1 )"
                    if [[ -s "$file" ]] ; then
                        if ! LC_ALL=C grep -qs "$file" "${order_file}" ; then
                            echo "$file" >> "${order_file}"
                        fi
                    else
                        NOREPORTS=1 el_error "Polkit startup file not found"
                        sleep 2
                    fi
                fi
            else
                is_polkit_auth_disabled_wanted=1
            fi

            # we don't want the daemon running, but user needs to access to disks, ask him
            if ((is_polkit_auth_disabled_wanted)) ; then
                if zenity --question --text="$( eval_gettext "Do you want to enable full disk access for this user?" )" ; then
                    #cat > /var/lib/polkit-1/localauthority/10-vendor.d/10-live-cd.pkla << EOF
                    cat > /tmp/.$(basename $0 )-${USER}.txt << EOF
# Policy to allow the user $USER to bypass policykit
[Elive special user permissions]
Identity=unix-user:${USER}
Action=*
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

                    el_dependencies_check "gksu"
                    gksu "cp /tmp/.$( basename $0 )-${USER}.txt /var/lib/polkit-1/localauthority/10-vendor.d/10-elive-user-${USER}.pkla"
                fi
            fi
        fi
    fi


    # gdu
    if ! ((is_live)) ; then
        if ! ((is_gdu_notif_included)) && ls /etc/xdg/autostart/gdu-notification*desktop 1>/dev/null 2>/dev/null ; then
            if zenity --question --text="$( eval_gettext "You have not included GDU notifications. This one is useful for alerting you in case errors are found on your hard disk. Are you sure you want to disable it?" )" ; then
                true
            else
                # re-enable it
                file="$( echo "$answer" | tr '|' '\n' | grep "/gdu.*notification" | head -1 )"
                if [[ -s "$file" ]] ; then
                    if ! LC_ALL=C grep -qs "$file" "${order_file}" ; then
                        echo "$file" >> "${order_file}"
                    fi
                else
                    # user may have removed it from the install
                    NOREPORTS=1 el_error "Gdu startup file not found"
                    #sleep 2
                fi
            fi
        fi
    fi

    # RUN the already selected .desktops to launch at start, otherwise we will have problems like authentications in the first boot (gparted or mounting disks failing)
    # update: deprecated, let's use 'elive-autostart-applications' intead



    # E16
    # also select which features (apps) we want to have by default:
    if [[ -n "$EROOT" ]] ; then
        unset menu result line

        # always enable notifications features (notify-send) by default:
        if [[ -x "/usr/lib/notification-daemon/notification-daemon" ]] ; then
            echo "/usr/lib/notification-daemon/notification-daemon" >> "$HOME/.e16/startup-applications.list"
        fi

        # include composite, only if the video card has enough power
        video_memory="$( glxinfo | grep "Video memory:" | sed -e 's|^.*memory: ||g' -e 's|MB.*$||g' )"
        if [[ "$video_memory" -ge 128 ]] || [[ -e "/tmp/.virtualmachine-detected" ]] ; then
            menu+=("TRUE")
        else
            menu+=("FALSE")
        fi
        menu+=("compositor")
        menu+=("Compositor: Enables transparencies and make dock look better")


        # conky
        if [[ -x "$(which 'conky' )" ]] ; then
            menu+=("TRUE")
            menu+=("conky")
            menu+=("Conky: resources visualizer gadget for desktop")
        fi

        # cairo-dock
        if [[ -x "$(which 'cairo-dock' )" ]] ; then
            menu+=("TRUE")
            menu+=("cairo-dock")
            menu+=("cairo-dock: A multiple feature dock for your desktop")

            # add the installer icon in live mode
            if ((is_live)) ; then
                cp -f "$HOME/.config/cairo-dock/current_theme/launchers/01launcher.desktop" "$HOME/.config/cairo-dock/current_theme/launchers/101launcher.desktop"
                sed -i "s|^Exec=.*$|Exec=eliveinstaller-wrapper|g" "$HOME/.config/cairo-dock/current_theme/launchers/101launcher.desktop"
                sed -i "s|^Order=.*$|Order=101.25|g" "$HOME/.config/cairo-dock/current_theme/launchers/101launcher.desktop"
                sed -i "s|^StartupWMClass=.*$|StartupWMClass=|g" "$HOME/.config/cairo-dock/current_theme/launchers/101launcher.desktop"
                sed -i "s|^prevent inhibate=.*$|prevent inhibate=true|g" "$HOME/.config/cairo-dock/current_theme/launchers/101launcher.desktop"
                sed -i "s|^Name=.*$|Name=Elive Installer|g" "$HOME/.config/cairo-dock/current_theme/launchers/101launcher.desktop"
                sed -i "s|^Icon=.*$|Icon=document-save|g" "$HOME/.config/cairo-dock/current_theme/launchers/101launcher.desktop"
            fi

        fi

        # include hexchat by default (going back to old times?)
        menu+=("FALSE")
        menu+=("hexchat")
        menu+=("IRC Chat: The Elive Chat channel in IRC")



        local message_1
        message_1="$( printf "$( eval_gettext "Select the desired features for your desktop. You can add more startup applications for your desktop by editing the file:" )" "" )"
        local message_2
        message_2="$( printf "$( eval_gettext "Enable" )" "" )"
        local message_3
        message_3="$( printf "$( eval_gettext "Description" )" "" )"


        if [[ -n "${menu[@]}" ]] ; then
            if grep -qs "thanatests" /proc/cmdline ; then
                result="compositor|conky|cairo-dock"
            else
                result="$( zenity --width="540" --list --checklist --text="${message_1}\n\n  ~/.e16/startup-applications.list\n" --column="$message_2" --column="command" --column="$message_3" --hide-column=2 "${menu[@]}"  || echo cancel )"
            fi
        fi

        # defaults in case the user canceled the dialog
        if [[ "$result" = "cancel" ]] ; then
            echo -e "conky" >> "$HOME/.e16/startup-applications.list"
            echo -e "cairo-dock" >> "$HOME/.e16/startup-applications.list"
            eesh compmgr start
            sleep 3
        else
            # selections by user
            if [[ -n "$result" ]] ; then
                while read -ru 3 line
                do
                    # run composite
                    if [[ "$line" = "compositor" ]] ; then
                        # we must enable compositor for it first:
                        eesh compmgr start
                        # wait that its started before to run other things:
                        sleep 3
                        # do not add to list, just continue
                        continue
                    fi

                    if [[ -x "$(which "$line" )" ]] ; then
                        # add to known list
                        echo "$line" >> "$HOME/.e16/startup-applications.list"

                        # run
                        # update: do not run: we will run them all later
                        #( $line & )

                    fi
                done 3<<< "$( echo "$result" | tr '|' '\n' )"
            fi
        fi
    fi

    # sort the resulting list to satisfy dependencies (like notification-daemon should be run first
    buf="$( cat "$HOME/.e16/startup-applications.list" )"
    echo "$buf" | sort | psort -- -p "notification-daemon" -p "elive-startup-sound" -p "/etc/" > "$HOME/.e16/startup-applications.list"


    # run them all (and wait for next hooks!)
    if [[ -x "$( which 'elive-autostart-applications' )" ]] ; then
        elive-autostart-applications "start"
    else
        # deprecated
        el_warning "not using elive-startup-applications, falling back to old mode"
        if test -s "${order_file}" ; then
            while read -ru 3 line
            do
                executable="$( grep "^Exec=" "$line" | sed -e 's|^Exec=||g' | tail -1 )"
                if [[ -n "$executable" ]] ; then
                    el_debug "running $executable"
                    bash -c "$executable & disown"
                else
                    # simple commands, not desktop files
                    bash -c "$line & disown"
                fi
            done 3<<< "$( cat "${order_file}" | sort -u )"
        fi
    fi


    #
    # Elive Retro (retrowave) version {{{
    #
    if [[ -e "/var/lib/dpkg/info/elive-skel-retrowave-all.list" ]] ; then
        sleep 5

        result="$( yad --width=400 --center --title="Elive Retro" \
            --form \
            --image=utilities-terminal --image-on-top --text="Elive RetroWave special version" \
            --field="$( eval_gettext "Play a selection of the best RetroWave music to improve your experience" ):chk" TRUE \
            --field="$( eval_gettext "Type mode" ):CB" "Play in a window!""Play in YouTube!""Radio SynthWave" \
            --field="$( eval_gettext "Open the Elive forum of this version" ):chk" FALSE \
            --field="Candies::lbl" \
            --field="$( eval_gettext "Retro Music Composer" ):chk" FALSE \
            --field="$( eval_gettext "Demo mode: run applications for the experience" ):chk" FALSE \
            --button="gtk-ok" || true )"
        #ret="$?"
        if [[ -n "$result" ]] ; then
            retro_play="$( echo "${result}" | awk -v FS="|" '{print $1}' )"
            retro_play_type="$( echo "${result}" | awk -v FS="|" '{print $2}' )"
            retro_forum="$( echo "${result}" | awk -v FS="|" '{print $3}' )"
            retro_music_composer="$( echo "${result}" | awk -v FS="|" '{print $4}' )"
            retro_demo_mode="$( echo "${result}" | awk -v FS="|" '{print $5}' )"
        else
            retro_play="TRUE"
            retro_play_type="Play in a window"
            retro_forum="FALSE"
            retro_music_composer="FALSE"
            retro_demo_mode="FALSE"
        fi

        # music retrowave
        if [[ "$retro_play" = "TRUE" ]] ; then
            case "$retro_play_type" in
                *"window"*)
                    mpv --no-config --profile=pseudo-gui --autofit=40% --ytdl --ytdl-format=18/22/bestaudio*/mp4   "https://youtube.com/?list=PL8StX6hh3Nd8JNRF75IOA9wnC8pKfB7cs" &
                    ;;
                *"YouTube"*)
                    web-launcher --app="https://youtube.com/?list=PL8StX6hh3Nd8JNRF75IOA9wnC8pKfB7cs" &
                    ;;
                *"Radio"*)
                    audacious -p &
                    ;;
            esac
        fi

        # forum
        if [[ "$retro_forum" = "TRUE" ]] ; then
            web-launcher "https://forum.elivelinux.org/c/special-versions/eliveretro/70" &
        fi


    fi


    # }}}


    # free some ram so the system is more clean after setting up the main desktop
    if ((is_live)) ; then
        wait
        sync
        LC_ALL=C sleep 0.3
        sudo bash -c "echo 3 > /proc/sys/vm/drop_caches"
    fi

    # if we are debugging give it a little pause to see what is going on
    #if grep -qs "debug" /proc/cmdline ; then
        #echo -e "debug: sleep 4" 1>&2
        #sleep 4
    #fi

}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
