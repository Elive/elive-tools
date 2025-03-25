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

    # debug mode
    if grep -Fqs "debug" /proc/cmdline ; then
        export EL_DEBUG=3
        if grep -Fqs "completedebug" /proc/cmdline ; then
            set -x
        fi
    fi


    RAM_TOTAL_SIZE_bytes="$( grep -F MemTotal /proc/meminfo | tr ' ' '\n' | grep "^[[:digit:]]*[[:digit:]]$" | head -1 )"
    RAM_TOTAL_SIZE_mb="$(( $RAM_TOTAL_SIZE_bytes / 1024 ))"
    RAM_TOTAL_SIZE_mb="${RAM_TOTAL_SIZE_mb%.*}"

    if grep -Fqs "boot=live" /proc/cmdline ; then
        is_live=1
    else
        if ! el_dependencies_check "zenity" ; then
            exit
        fi
    fi

        # determine the mount version
    case "$( cat /etc/debian_version )" in
        12.*|"bookworm"*)
            is_bookworm=1
            ;;
        #11.*|"bullseye"*)
            #is_bullseye=1
            #;;
        #10.*|"buster"*)
            #is_buster=1
            #;;
        #7.*|"wheezy"*)
            #is_wheezy=1
            #;;
    esac


    if grep -Fqs "thanatests" /proc/cmdline ; then
        is_thanatests=1
    fi

    if [[ -e /tmp/.no-keyboard ]] ; then
        is_keyboard_notfound=1
    fi

    if hcitool dev | grep -qs ":.*:.*:" ; then
        is_bluetooth_availble=1
    fi

    # }}}

    if [[ -n "$EROOT" ]] ; then
        # e16
        order_file="$HOME/.e16/startup-applications.list"
        is_e16=1
    else
        if [[ -x "$(which enlightenment)" ]] ; then
            if [ -n "$E_START" ] && [ -z "$E_HOME_DIR" ] ; then
                E_HOME_DIR="$HOME/.e/e17"
            fi
            order_file="$E_HOME_DIR/applications/startup/.order"
            is_enlightenment=1
            # E_VERSION="$( enlightenment --version | grep "^Version: " | sed -e 's|^Version: ||g' | tail -1 )"
            # case "$E_VERSION" in
            #     0.17.*)
            #         order_file="$HOME/.e/e17/applications/startup/.order"
            #         ;;
            #     *)
            #         el_error "unknown version of Enlightenment, ignoring selection of startup applications: '$E_VERSION' "
            #         exit
            #         ;;
            # esac
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

        #filename="$( basename "$file" )"
        filename="${file}"
        filename="${filename%/}"
        filename="${filename##*/}"

        # - checks }}}
        # un-needed / blacklisted ones {{{
        if [[ -n "$EROOT" ]] ; then
            # E16 requires different ones
            if echo "$filename" | LC_ALL=C grep -qsEi "^(kde|glipper-|print-applet|notification-daemon|user-dirs-update-gtk|elive-support-donations|org.gnome.SettingsDaemon|gnome-software-service|tracker-store|pulseaudio|at-spi)" ; then
                # glipper: we want to enable it in a different way: if ctrl+alt+c si pressed, run it for 8 hours long and close/kill it to save mem
                # nm-applet: already integrated in elive correctly and saving mem
                #       e16 doesn't has a module or anything so keep it running from the trayer
                # wicd-: deprecated and not needed for elive
                # print-applet: useless
                # notification-daemon: dont include it if we are going to use e17's one
                # user-dirs-update-gtk: we dont want to run the "directories renamer", becuase: 1) it doesnt move files to the new dirs, 2) its async and can conflict with our renamer, 3) our renamer (e17 restart conf hooks) already does it, it mess up and fucks the users! they should be NEVER renamed after the system is set up, no matter what! even scripts can point to them not-dynamically
                # elive-assistant-inspirateme: very nice but we don't want to popup this from the start, so just suggest to enable it after a successfull configuration (by user)
                # elive-support-donations: this is simply annoying to have, even monthly showing (lol), but since we have upgrades with changelogs asking for possible donations that does the same (better) job, so disable this one by default
                # pulseaudio*: starte16 already starts it, and its needed to start it before the desktop starts otherwise we could have an error in desktop
                continue
            fi

        else
            # E17 / E22
            if echo "$filename" | LC_ALL=C grep -qsEi "^(kde|glipper-|nm-applet|wicd-|print-applet|notification-daemon|user-dirs-update-gtk|elive-support-donations|org.gnome.SettingsDaemon|gnome-software-service|tracker-store|pulseaudio|at-spi)" ; then
                # glipper: we want to enable it in a different way: if ctrl+alt+c si pressed, run it for 8 hours long and close/kill it to save mem
                # nm-applet: already integrated in elive correctly and saving mem
                # wicd-: deprecated and not needed for elive
                # print-applet: useless
                # notification-daemon: dont include it if we are going to use e17's one
                # user-dirs-update-gtk: we dont want to run the "directories renamer", becuase: 1) it doesnt move files to the new dirs, 2) its async and can conflict with our renamer, 3) our renamer (e17 restart conf hooks) already does it, it mess up and fucks the users! they should be NEVER renamed after the system is set up, no matter what! even scripts can point to them not-dynamically
                # elive-assistant-inspirateme: very nice but we don't want to popup this from the start, so just suggest to enable it after a successfull configuration (by user)
                # elive-support-donations: this is simply annoying to have, even monthly showing (lol), but since we have upgrades with changelogs asking for possible donations that does the same (better) job, so disable this one by default
                continue
            fi
        fi
        # - un-needed ones }}}
        # default to enabled/disabled {{{

        case "$filename" in
            # do we need a touch-screen keyboard?
            "onboard-autostart.desktop")
                if ((is_keyboard_notfound)) ; then
                    menu+=("TRUE")
                    menu_auto+=("$file")
                    menu_auto_live+=("$file")
                    #el_debug "state: TRUE"
                else
                    menu+=("FALSE")
                    #el_debug "state: FALSE"
                fi
                ;;
            "blueman.desktop")
                # make sure we have bluetooth device
                if ((is_bluetooth_availble)) ; then
                    if [[ -n "$EROOT" ]] ; then
                        if ((is_live)) ; then
                            menu+=("TRUE")
                        else
                            menu+=("FALSE")
                        fi
                        # menu_auto+=("$file")
                        menu_auto_live+=("$file")
                        #el_debug "state: TRUE"
                    else
                        menu+=("FALSE")
                        #el_debug "state: FALSE"
                    fi
                else
                    menu+=("FALSE")
                    #el_debug "state: FALSE"
                fi
                ;;

            "gnome-keyring"*|"update-notifier"*)
                # in installed, but not in low RAM
                # update: always required for wifi passwords
                # if [[ "$RAM_TOTAL_SIZE_mb" -gt 900 ]] ; then
                    menu+=("TRUE")
                    menu_auto+=("$file")
                    menu_auto_live+=("$file")
                    #el_debug "state: TRUE"
                # fi
                ;;
            "polkit"*|"pulseaudio"*)
                # always needed these
                menu+=("TRUE")
                menu_auto+=("$file")
                menu_auto_live+=("$file")
                #el_debug "state: TRUE"
                ;;
            "gdu-notif"*|"user-dirs-update"*|"update-notifier"*)
                # only for installed system
                menu+=("TRUE")
                menu_auto+=("$file")
                #el_debug "state: TRUE"
                ;;
            "elive-assistant-inspirateme"*)
                # do not auto-enable
                menu+=("FALSE")
                #el_debug "state: FALSE"
                ;;
            "elive-"*)
                # always enable
                menu+=("TRUE")
                menu_auto+=("$file")
                menu_auto_live+=("$file")
                #el_debug "state: TRUE"
                ;;
            "lockfs-notify"*)
                # only for installed system
                menu+=("TRUE")
                menu_auto+=("$file")
                #el_debug "state: TRUE"
                ;;

            "nm-applet"*|*"DejaDup.Monitor"*|*"at-spi"*)
                menu+=("FALSE")
                #el_debug "state: FALSE"
                ;;

            *)
                NOREPORTS=1 el_warning "unlisted / unknown autolauncher: $filename"
                menu+=("FALSE")
                #el_debug "state: FALSE"
                ;;
        esac


        # - default to enabled/disabled }}}

        # include file
        menu+=("$file")
        #el_debug "file: $file"

        # include name {{{
        if [[ "${LANG%%.*}" = "en_US" ]] ; then
            name="$( LC_ALL=C grep "^Name=" "$file" | head -1 )"
        fi
        if [[ -z "$name" ]] ; then
            name="$( grep "^Name\[${LANG%%_*}\]" "$file" | head -1 )"
            if [[ -z "$name" ]] ; then
                #name="$( grep "^Name\[${LANG%%.*}" "$file" | head -1 )"
                #if [[ -z "$name" ]] ; then
                name="$( grep "^Name\[${LANG%%.*}\]" "$file" | head -1 )"
                    if [[ -z "$name" ]] ; then
                        name="$( grep "^Name\[${LANG%%_*}" "$file" | head -1 )"
                        if [[ -z "$name" ]] ; then
                            name="$( grep "^Name=" "$file" | head -1 )"
                            if [[ -z "$name" ]] ; then
                                name="$( basename "${file%.*}" )"
                            fi
                        fi
                    fi
                #fi
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
        #el_debug "name: ${name}"

        # }}}
        # include comment {{{
        if [[ "${LANG%%.*}" = "en_US" ]] ; then
            comment="$( LC_ALL=C grep "^Comment=" "$file" | head -1 )"
        fi
        if [[ -z "$comment" ]] ; then
            comment="$( grep "^Comment\[${LANG%%_*}\]" "$file" | head -1 )"
            if [[ -z "$comment" ]] ; then
                #comment="$( grep "^Comment\[${LANG%%.*}" "$file" | head -1 )"
                #if [[ -z "$comment" ]] ; then
                comment="$( grep "^Comment\[${LANG%%.*}\]" "$file" | head -1 )"
                    if [[ -z "$comment" ]] ; then
                        comment="$( grep "^Comment=" "$file" | head -1 )"
                        if [[ -z "$comment" ]] ; then
                            comment="$( grep "^Comment\[${LANG%%_*}" "$file" | head -1 )"
                        fi
                    fi
                #fi
            fi
        fi

        # empty?
        if [[ -z "$comment" ]] ; then
            comment="(without description)"
        fi
        comment="${comment#*]=}"
        comment="${comment#Comment=}"
        # add comment
        menu+=("${comment}")
        #el_debug "comment: ${comment}"

        #el_debug "       (loop)"
        # }}}

    done 3<<< "$( find /etc/xdg/autostart/ "$HOME/.config/autostart/" -type f -iname '*'.desktop | sort -u )"


    if [[ "$RAM_TOTAL_SIZE_mb" -lt 700 ]] ; then
        message_gui="$( printf "$( eval_gettext "Select the services you want enabled for your desktop. Note that you have limited RAM, and services will use it. Elive has pre-selected the best options for you." )" )"
    else
        message_gui="$( printf "$( eval_gettext "Select the services you want enabled on your desktop. The chosen ones are already preselected to ensure correct compatibility with your system." )" )"
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
        if ! LC_ALL=C grep -Fqs "elxstrt.desktop" "${order_file}" ; then
            echo "$HOME/.local/share/applications/elxstrt.desktop" >> "${order_file}"
        fi
    fi


    while read -ru 3 file
    do
        if [[ -s "$file" ]] ; then
            filename="${file%/}"
            filename="${filename##*/}"

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
                if zenity --question --text="$( eval_gettext "The Polkit authentication agent is not included, needed for proper system function (e.g., using media devices or mounting hard disks). Elive can add a special config for disk use. Are you sure you want to disable it?" )" ; then
                    is_polkit_auth_disabled_wanted=1
                else
                    # re-enable it
                    file="$( echo "$answer" | tr '|' '\n' | grep "/polkit.*authentication" | head -1 )"
                    if [[ -s "$file" ]] ; then
                        if ! LC_ALL=C grep -Fqs "$file" "${order_file}" ; then
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
                if zenity --question --text="$( eval_gettext "Do you want to enable full hard disk access for this user? (recommended)" )" ; then
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
                    gksu cp /tmp/.$( basename $0 )-${USER}.txt "/var/lib/polkit-1/localauthority/10-vendor.d/10-elive-user-${USER}.pkla"
                fi
            fi
        fi
    fi


    # gdu
    if ! ((is_live)) ; then
        if ! ((is_gdu_notif_included)) && ls /etc/xdg/autostart/gdu-notification*desktop 1>/dev/null 2>/dev/null ; then
            if zenity --question --text="$( eval_gettext "GDU notifications are not included. These alert you to hard disk errors. Are you sure you want to disable them?" )" ; then
                true
            else
                # re-enable it
                file="$( echo "$answer" | tr '|' '\n' | grep "/gdu.*notification" | head -1 )"
                if [[ -s "$file" ]] ; then
                    if ! LC_ALL=C grep -Fqs "$file" "${order_file}" ; then
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
        local message_compositor
        message_compositor="$( printf "$( eval_gettext "Compositor: Enables transparencies and make the dock bar look better" )" "" )"
        local message_conky
        message_conky="$( printf "$( eval_gettext "Conky: resources visualizer gadget for desktop" )" "" )"
        local message_sound
        message_sound="$( printf "$( eval_gettext "Activate desktop sound effects" )" "" )"
        local message_dock
        message_dock="$( printf "$( eval_gettext "cairo-dock: A multiple featured Dock bar for your desktop" )" "" )"
        local message_hexchat
        message_hexchat="$( printf "$( eval_gettext "IRC Chat: With the chat channel of Elive" )" "" )"

        # always enable notifications features (notify-send) by default:
        if [[ -x "/usr/lib/notification-daemon/notification-daemon" ]] && [[ -e "$HOME/.e16/startup-applications.list" ]] && ! grep -qs "notification-daemon" "$HOME/.e16/startup-applications.list" ; then
            echo "/usr/lib/notification-daemon/notification-daemon" >> "$HOME/.e16/startup-applications.list"
        fi

        # include composite, only if the video card has enough power
        video_memory="$( glxinfo | grep -i "Video memory:" | sed -e 's|^.*memory: ||g' -e 's|MB.*$||g' | head -1 )"
        if [[ "$video_memory" -ge 128 ]] || [[ -e "/tmp/.virtualmachine-detected" ]] ; then
            menu+=("TRUE")
        else
            menu+=("FALSE")
        fi
        menu+=("compositor")
        menu+=("${message_compositor}")


        # conky
        if [[ -x "$(which 'conky' )" ]] ; then
            menu+=("TRUE")
            menu+=("conky")
            menu+=("${message_conky}")
        fi

        # desktop sound effects
        hour="$(date +%k)"
        if [[ -s "/etc/elive-tools/geolocation/livemode-location-fetched.txt" ]] && [[ "${hour}" -lt "21" ]] && [[ "$hour" -gt "8" ]] && ! ((is_thanatests)) && ((is_live)) ; then
            menu+=("TRUE")
        else
            menu+=("FALSE")
        fi
        menu+=("soundeffects")
        menu+=("${message_sound}")


        # cairo-dock
        if [[ -x "$(which 'cairo-dock' )" ]] ; then
            menu+=("TRUE")
            menu+=("cairo-dock")
            menu+=("${message_dock}")

            # add the installer icon in live mode
            if ((is_live)) ; then
                cp -f "$HOME/.config/cairo-dock/current_theme/launchers/01launcher.desktop" "$HOME/.config/cairo-dock/current_theme/launchers/101launcher.desktop"
                sed -i "s|^Exec=.*$|Exec=eliveinstaller-wrapper|g" "$HOME/.config/cairo-dock/current_theme/launchers/101launcher.desktop"
                sed -i "s|^Order=.*$|Order=101.25|g" "$HOME/.config/cairo-dock/current_theme/launchers/101launcher.desktop"
                sed -i "s|^StartupWMClass=.*$|StartupWMClass=|g" "$HOME/.config/cairo-dock/current_theme/launchers/101launcher.desktop"
                sed -i "s|^prevent inhibate=.*$|prevent inhibate=true|g" "$HOME/.config/cairo-dock/current_theme/launchers/101launcher.desktop"
                sed -i "s|^Name=.*$|Name=Elive Installer|g" "$HOME/.config/cairo-dock/current_theme/launchers/101launcher.desktop"
                sed -i "s|^Icon=.*$|Icon=system-os-install|g" "$HOME/.config/cairo-dock/current_theme/launchers/101launcher.desktop"
            fi

        fi

        # include hexchat by default (going back to old times?)
        menu+=("FALSE")
        menu+=("hexchat")
        menu+=("${message_hexchat}")



        local message_1
        message_1="$( printf "$( eval_gettext "Select the desired features for your desktop. You can add more startup applications by editing the file:" )" "" )"
        local message_2
        message_2="$( printf "$( eval_gettext "Enable" )" "" )"
        local message_3
        message_3="$( printf "$( eval_gettext "Description" )" "" )"


        if [[ -n "${menu[@]}" ]] ; then
            if ((is_thanatests)) ; then
                result="compositor|conky|cairo-dock"
            else
                result="$( zenity --width="540" --height="290" --list --checklist --text="${message_1}  ~/.e16/startup-applications.list\n" --column="$message_2" --column="command" --column="$message_3" --hide-column=2 "${menu[@]}"  || echo cancel )"
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
                    case "$line" in
                        "soundeffects")
                            eesh -e sound on
                            continue
                            ;;
                        "compositor")
                            # we must enable compositor for it first:
                            eesh compmgr start
                            # wait that its started before to run other things:
                            sleep 3
                            # do not add to list, just continue
                            continue
                            ;;
                    esac

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

    # add an info header
    rm -f "$HOME/.e16/startup-applications.list"
    local message_instructions
    message_instructions="$( printf "$( eval_gettext "INSTRUCTIONS: To add an application to run at startup, simply add it to this list. If you want to disable one, comment the line (using the hashtag symbol at the start of the line) so it will be ignored. However, do not remove the line, as Elive may suggest adding it again in the future." )" "" )"
    echo "# $message_instructions" >> "$HOME/.e16/startup-applications.list"

    # sort the launchers
    echo "$buf" | sort | psort -- -p "notification-daemon" -p "elive-startup-sound" -p "/etc/" >> "$order_file"

    # fix for bookworm asking for wifi password, for some reason even if the daemon is correctly running, this needs to be run again otherwise wifi password asking will not show up
    if ((is_live)) && ((is_bookworm)) ; then
        if ((is_e16)) ; then
            echo "gnome-keyring-daemon" >> "$HOME/.e16/startup-applications.list"
        fi
        if ((is_enlightenment)) ; then
            if ! LC_ALL=C grep -Fqs "gnome-keyring-daemon" "$HOME/.elxstrt" ; then
                echo -e "\n# Fix for bookworm on which the keyring is not working and needs to be run again:\nkillall gnome-keyring-daemon 2>/dev/null 1>&2 || true\ngnome-keyring-daemon &" >> "$HOME/.elxstrt"
            fi
        fi
    fi

    # configure cairo-dock
    source /etc/elive/machine-profile 2>/dev/null || true
    if ! laptop-detect || [[ "$MACHINE_VIRTUAL" = "yes" ]] ; then
        sed -i -e '/^modules=/s|PowerManager;||g' "$HOME/.config/cairo-dock/current_theme/cairo-dock.conf"
        sed -i -e '/^modules=/s|PowerManager||g' "$HOME/.config/cairo-dock/current_theme/cairo-dock.conf"
    fi


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
    # Welcome instructions & demo {{{
    #
    if ! ((is_thanatests)) ; then

        _chk_hotkeys=FALSE
        if ! ((is_live)) && [[ -x "/usr/bin/elive-help" ]] ; then
            _chk_hotkeys=TRUE
        fi

        local message_desc
        source /etc/os-release

        # Elive Retro version
        if [[ -e "/var/lib/dpkg/info/elive-skel-retrowave-all.list" ]] ; then
            is_version_retro=1
            message_desc="$( printf "$( eval_gettext "Elive RetroWave - special version" )" "" ) $VERSION"
            play_music="TRUE"
        else
            message_desc="$PRETTY_NAME"
            play_music="FALSE"
        fi

        # show generic menu for all the versions:
        result="$( yad --width=400 --center --title="Elive Intro" \
            --form \
            --image=utilities-terminal --image-on-top --text="$message_desc" \
            --field="$( eval_gettext "1-minute instructions" ):chk" TRUE \
            --field="$( eval_gettext "Play a selection of the best RetroWave music" ):chk" $play_music \
            --field="$( eval_gettext "Mode" ):CB" "Play in a window!""Play in YouTube!""Radio SynthWave" \
            --field="$( eval_gettext "Show me the Elive hotkeys" ):chk" $_chk_hotkeys \
            --field="$( eval_gettext "Open the Elive forum." ):chk" FALSE \
            --button="gtk-ok" || true )"
        #ret="$?"

            #--field="Candies::lbl" \
            #--field="$( eval_gettext "Retro Music Composer" ):chk" FALSE \
            #--field="$( eval_gettext "Demo mode: run applications for the experience" ):chk" FALSE \

        if [[ -n "$result" ]] ; then
            demo_instructions="$( echo "${result}" | awk -v FS="|" '{print $1}' )"
            retro_play="$( echo "${result}" | awk -v FS="|" '{print $2}' )"
            retro_play_type="$( echo "${result}" | awk -v FS="|" '{print $3}' )"
            demo_hotkeys="$( echo "${result}" | awk -v FS="|" '{print $4}' )"
            retro_forum="$( echo "${result}" | awk -v FS="|" '{print $5}' )"
            #retro_music_composer="$( echo "${result}" | awk -v FS="|" '{print $4}' )"
            #retro_demo_mode="$( echo "${result}" | awk -v FS="|" '{print $5}' )"
        else
            retro_play="FALSE"
            retro_play_type="Play in a window"
            demo_instructions="FALSE"
            demo_hotkeys="FALSE"
            retro_forum="FALSE"
            #retro_music_composer="FALSE"
            #retro_demo_mode="FALSE"
        fi
        #else

            ## Normal versions:
            #result="$( yad --width=400 --center --title="Elive Welcome Menu" \
                #--form \
                #--image=utilities-terminal --image-on-top --text="Elive instructions and demo" \
                #--field="$( eval_gettext "1-minute instructions" ):chk" TRUE \
                #--field="$( eval_gettext "Show me the Elive hotkeys" ):chk" $_chk_hotkeys \
                #--button="gtk-ok" || true )"
            ##ret="$?"
            #if [[ -n "$result" ]] ; then
                #demo_instructions="$( echo "${result}" | awk -v FS="|" '{print $1}' )"
                #demo_hotkeys="$( echo "${result}" | awk -v FS="|" '{print $2}' )"
            #else
                #demo_instructions="FALSE"
                #demo_hotkeys="FALSE"
            #fi
        #fi
    fi

    # run this in a subshell waiting for internet because we depend on it
    (
    count=0
    while true
    do
        if el_verify_internet fast ; then
            break
        fi
        sleep 5
        count="$(( $count + 1 ))"

        # 4 minutes:
        if [[ "$count" -gt 60 ]] ; then
            break
        fi
    done

    # performance formats:
    # 18  mp4   640x360
    # 22  mp4   1280x720

    # instructions video, first one to run
    if [[ "$demo_instructions" = "TRUE" ]] ; then
        precache mpv 1>/dev/null ; mpv "" 2>/dev/null || true

        # set the window without buttons which looks better
        (
        if eesh border list | grep -qs BUTTONLESS ; then
            for count in $( seq 30 )
            do
                buf="$( eesh wl prop "mpv" | grep "0x" | tail -1 | awk '{print $1}' )"
                if [[ "$buf" = "0x"* ]] ; then
                    sleep 10 # wait that the window appears first
                    eesh wop "$buf" border BUTTONLESS
                    break
                fi
                sleep 1
                count="$(( $count + 1 ))"
            done
        fi
        )

        if [[ "$(el_resolution_get horiz)" -lt 1900 ]] || [[ "$RAM_TOTAL_SIZE_mb" -lt 3300 ]] ; then
            mpv --no-config --profile=pseudo-gui --autofit=80% --ytdl --ytdl-format=22/mp4 --start=0 --cache=yes  "https://www.elivecd.org/video-instructions-01"
        else
            mpv --no-config --profile=pseudo-gui --autofit=80% --start=0 --cache=yes  "https://www.elivecd.org/video-instructions-01"
        fi
    fi

    # hotkeys pdf
    if [[ "$demo_hotkeys" = "TRUE" ]] ; then
        if [[ -x "/usr/bin/elive-help" ]] ; then
            elive-help --hotkeys --fs --iconify --preview &
        fi
    fi


    # music retrowave
    if [[ "$retro_play" = "TRUE" ]] ; then
        case "$retro_play_type" in
            *"window"*|*"Window"*)
                precache mpv 1>/dev/null ; mpv "" 2>/dev/null || true
                ( mpv --no-config --profile=pseudo-gui --autofit=60% --ytdl --ytdl-format=18/22/bestaudio*/mp4   "https://www.youtube.com/?list=PL8StX6hh3Nd8JNRF75IOA9wnC8pKfB7cs" & )
                # wait so that the PDF will run after this window, if we want to close it we will not close mpv accidentally
                sleep 2
                ;;
            *"YouTube"*|*"Youtube"*|*"youtube"*)
                web-launcher --delay=2 --app="https://www.youtube.com/watch?v=OXgwyZe_FeY&list=PL8StX6hh3Nd8JNRF75IOA9wnC8pKfB7cs" &
                ;;
            *"Radio"*|*"radio"*)
                audacious -p &
                ;;
        esac
    fi

    # forum
    if [[ "$retro_forum" = "TRUE" ]] ; then
        if ((is_version_retro)) ; then
            web-launcher --delay=10 "https://forum.elivelinux.org/c/special-versions/eliveretro/70" &
        else
            web-launcher --delay=10 "https://forum.elivelinux.org/" &
        fi
    fi


    # finished bg waiting for internet tasks
    ) &


    # }}}


    # free some ram so the system is more clean after setting up the main desktop
    if ((is_live)) ; then
        sync
        LC_ALL=C sleep 0.3
        sudo bash -c "echo 3 > /proc/sys/vm/drop_caches"
        sudo rm -f /run/live/overlay/rw/home/*/.cache/fontconfig/* 2>/dev/null || true
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
