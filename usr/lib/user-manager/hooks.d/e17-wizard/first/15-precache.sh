#!/bin/sh

precache(){
    # precache desktop files in BG while we wait for language to select
    if [ -n "$EROOT" ] ; then
        bash -c "precache --nice /etc/xdg/autostart/*desktop /usr/share/applications/*desktop /usr/share/xdgeldsk/applications/*desktopp $(which cairo-dock) $(which conky) $(which zenity) $(which yad) /usr/lib/notification-daemon/notification-daemon   1>/dev/null 2>&1  & disown"
    elses
        bash -c "precache --nice /etc/xdg/autostart/*desktop /usr/share/applications/*desktop /usr/share/xdgeldsk/applications/*desktopp $(which zenity) $(which yad)  1>/dev/null 2>&1  & disown"
    fi
}

precache
