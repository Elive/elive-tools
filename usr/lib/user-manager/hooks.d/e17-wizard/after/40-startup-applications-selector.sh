#!/bin/bash
source /usr/lib/elive-tools/functions
el_make_environment
. gettext.sh
TEXTDOMAIN="elive-tools"
export TEXTDOMAIN


main(){
    # pre {{{
    local file menu menu_auto menu_auto_live message_gui

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
        if [[ "$(which enlightenment)" ]] ; then
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
            if echo "$filename" | grep -qsEi "^(kde|glipper-|print-applet|notification-daemon|user-dirs-update-gtk|elive-support-donations)" ; then
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
            if echo "$filename" | grep -qsEi "^(kde|glipper-|nm-applet|wicd-|print-applet|notification-daemon|user-dirs-update-gtk|elive-support-donations)" ; then
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
            if echo "$filename" | grep -qsEi "^(pulseaudio)" ; then
                # pulseaudio*: starte16 already starts it, and its needed to start it before the desktop starts otherwise we could have an error in desktop
                # update: not sure if this is needed anymore (and remove from starte16)
                continue
            fi
        fi
        # - un-needed ones }}}
        # default to enabled/disabled {{{

        if [[ "$RAM_TOTAL_SIZE_mb" -gt 900 ]] ; then
            if echo "$filename" | grep -qsEi "^(polkit|gdu-notif|gnome-|user-dirs-update|update-notifier|pulseaudio|elive-)" ; then
                menu+=("TRUE")
                menu_auto+=("$file")
                el_debug "state: TRUE"
            else
                menu+=("FALSE")
                el_debug "state: FALSE"
            fi
        else
            if echo "$filename" | grep -qsEi "^(polkit|gdu-notif|user-dirs-update|pulseaudio|elive-)" ; then
                menu+=("TRUE")
                menu_auto+=("$file")
                el_debug "state: TRUE"
            else
                menu+=("FALSE")
                el_debug "state: FALSE"
            fi
        fi

        # auto menu for live mode
        if echo "$filename" | grep -qsEi "^(polkit|elive-|gnome-|pulseaudio)" ; then
            menu_auto_live+=("$file")
        fi
        # - default to enabled/disabled }}}

        # include file
        menu+=("$file")
        el_debug "file: $file"

        # include name {{{
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

    done 3<<< "$( find /etc/xdg/autostart/ -type f -iname '*'.desktop | sort -u )"


    if [[ "$RAM_TOTAL_SIZE_mb" -lt 700 ]] ; then
        message_gui="$( printf "$( eval_gettext "Select the services that you want to have enabled on your desktop. Note that you don't have much RAM memory and they will use it. Elive has already selected the best option for you." )" )"
    else
        message_gui="$( printf "$( eval_gettext "Select the services that you want to have enabled on your desktop. Elive has already selected the best option for you." )" )"
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
        answer="$( timeout 340 zenity --list --checklist --height=580 --width=630 --text="$message_gui"  --column="" --column="" --column="$( eval_gettext "Name" )" --column="$( eval_gettext "Comment" )" "${menu[@]}" --print-column=2 --hide-column=2 || echo cancel )"

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
        if ! grep -qs "elxstrt.desktop" "${order_file}" ; then
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

            if ! grep -qs "^${file}$" "${order_file}" ; then
                echo "$file" >> "${order_file}"
            fi
        fi
    done 3<<< "$( echo "$answer" | tr '|' '\n' )"

    # polkit auth

    if ! ((is_live)) ; then
        if ! ((is_polkit_auth_included)) ; then
            if ls /etc/xdg/autostart/polkit-*authentication*desktop 1>/dev/null 2>/dev/null ; then
                if zenity --question --text="$( eval_gettext "You have not included Polkit authentication agent, but is very important for the correct work of your system, it allows you to use media devices or mount hard disks. But Elive can add a special configuration that can allows you to still use perfectly the disks, are you sure that you want to disable it ?" )" ; then
                    is_polkit_auth_disabled_wanted=1
                else
                    # re-enable it
                    file="$( echo "$answer" | tr '|' '\n' | grep "/polkit.*authentication" | head -1 )"
                    if [[ -s "$file" ]] ; then
                        if ! grep -qs "$file" "${order_file}" ; then
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
            if zenity --question --text="$( eval_gettext "You have not included Gdu Notification. This one is useful for alerting you in case there are errors discovered on your hard disk. Are you sure you want to disable it ?" )" ; then
                true
            else
                # re-enable it
                file="$( echo "$answer" | tr '|' '\n' | grep "/gdu.*notification" | head -1 )"
                if [[ -s "$file" ]] ; then
                    if ! grep -qs "$file" "${order_file}" ; then
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
    if test -s "${order_file}" ; then
        while read -ru 3 line
        do
            executable="$( grep "^Exec=" "$line" | sed -e 's|^Exec=||g' | tail -1 )"
            if [[ -n "$executable" ]] ; then
                el_debug "running $executable"
                bash -c "$executable & disown"
            fi
        done 3<<< "$( cat "${order_file}")"
    fi



    # E16
    # also select which features (apps) we want to have by default:
    if [[ -n "$EROOT" ]] ; then
        # conky
        if [[ -x "$(which 'conky' )" ]] ; then
            menu+=("TRUE")
            menu+=("conky")
            menu+=("conky: resources visualizer gadget for desktop")
        fi

        # cairo-dock
        if [[ -x "$(which 'cairo-dock' )" ]] ; then
            menu+=("TRUE")
            menu+=("cairo-dock")
            menu+=("cairo-dock: A powerful and featured dock for your desktop")
        fi


        local message_1
        message_1="$( printf "$( eval_gettext "Select the applications to automatically start on your desktop" )" "" )"
        local message_2
        message_2="$( printf "$( eval_gettext "Enable" )" "" )"
        local message_3
        message_3="$( printf "$( eval_gettext "Application" )" "" )"


        if [[ -n "${menu[@]}" ]] ; then
            result="$( zenity --width="540" --list --checklist --text="$message_1" --column="$message_2" --column="command" --column="$message_3" --hide-column=2 "${menu[@]}"  || echo cancel )"
        fi

        if [[ -n "$result" ]] && [[ "$result" != "cancel" ]] ; then
            while read -ru 3 line
            do
                if [[ -x "$(which "$line" )" ]] ; then
                    # add to known list
                    echo "$line" >> "$HOME/.e16/startup-applications.list"
                    # run it too
                    ( $line & )
                fi
            done 3<<< "$( echo "$result" | tr '|' '\n' )"
        fi
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
