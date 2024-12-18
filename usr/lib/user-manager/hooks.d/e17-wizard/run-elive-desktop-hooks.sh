#!/bin/bash
source /usr/lib/elive-tools/functions

run_all_hooks(){
    # pre {{{
    local hook step steps hooksdir logs

    if grep -Fqs "debug" /proc/cmdline ; then
      export EL_DEBUG=5
      is_debug=1
    fi

    # }}}
    if [[ -n "$1" ]] ; then
        steps="$1"
        shift
    else
        steps="first last after"
    fi

    if grep -qs "boot=live" /proc/cmdline ; then
        hooksdir="deliver"
    else
        hooksdir="user-manager"
    fi

    # wait a few seconds if we are in E26
    if [[ -n "$E_HOME_DIR" ]] ; then
        sleep 4
    fi

    for step in $steps
    do
        for hook in "/usr/lib/$hooksdir/hooks.d/e17-wizard/$step/"*
        do
            if [[ -e "$hook" ]] ; then
                el_debug "running $hook"
                # run hook and get all the possible error messages (only, not standard output)
                if [[ "$hook" =  *"audio-configuration"* ]] ; then
                    # by some reason this doesn't plays the audio in BG and we want that for speed, so run without the pipes:
                    if ((is_debug)) ; then
                      urxvt -hold -g 120x40 -title "$step - $hook" -e bash -c "set -x ; $hook ; echo DONE"
                    else
                      "$hook"
                    fi
                else
                  if ((is_debug)) ; then
                    urxvt -hold -g 120x40 -title "$step - $hook" -e bash -c "set -x ; $hook ; echo DONE"
                  else
                    "$hook" 1>/dev/null 2>>/tmp/.X11-error-logs-desktop-hooks.txt
                  fi
                fi
                el_debug "done hook $hook"
            fi
        done
    done

    # remove useless / known logs
    logs="$( cat "/tmp/.X11-error-logs-desktop-hooks.txt" | grep -vE "(^Terminating|conky|/run/user/.*/keyring/|cairo-dock)" | sed -e 's|^ $||g' -e '/^$/d' )"
    rm -f "/tmp/.X11-error-logs-desktop-hooks.txt"

    if [[ -n "$logs" ]] ; then
        el_error "possible errors catched in the logs of the desktop startup hooks:\n${logs}"
    fi


    # when this process finishes, it sends a "sighup" signal which restarts applications twice
    # fix cairo-dock & conky:
    LC_ALL=C sleep 12
    if [[ "$( pidof cairo-dock | wc -w )" -ge 2 ]] ; then
        killall cairo-dock 1>/dev/null 2>&1
        killall -9 cairo-dock 1>/dev/null 2>&1
        bash -c "cairo-dock  & disown"
    fi
    if [[ "$( pidof conky | wc -w )" -ge 2 ]] ; then
        killall conky 1>/dev/null 2>&1
        killall -9 conky 1>/dev/null 2>&1
        bash -c "conky  & disown"
    fi

}

main(){
    # run it in BG so we don't need to wait for desktop start
    if ((is_terminal)) || [[ -n "$E_START" ]] ; then
        run_all_hooks "$@"
    else
        run_all_hooks "$@" &
    fi
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
