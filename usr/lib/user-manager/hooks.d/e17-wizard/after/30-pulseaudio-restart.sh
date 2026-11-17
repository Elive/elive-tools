#!/bin/sh

main(){
    command -v el_debug >/dev/null 2>&1 || el_debug(){ if [ "${EL_DEBUG:-0}" -gt 2 ]; then echo "$@" >&2; fi; }


    # disabled
    el_debug "ignoring restarting audio devices... it should work correctly by default"
    exit 0



    el_debug "Starting audio service restart handling"

    if [ "${is_pipewire:-0}" -ne 0 ] || [ -x "$(which pipewire)" ]; then
        el_debug "PipeWire audio server detected"
        if [ "${is_systemd:-0}" -ne 0 ]; then
            systemctl --user restart pipewire pipewire-pulse wireplumber 2>/dev/null || true
        elif [ "${is_openrc:-0}" -ne 0 ] || [ "${is_sysvinit:-0}" -ne 0 ]; then
            sudo service pipewire restart 2>/dev/null || true
        else
            killall pipewire pipewire-pulse wireplumber 2>/dev/null || true
            pipewire &
        fi
    elif [ "${is_pulseaudio:-0}" -ne 0 ] || [ -x "$(which pulseaudio)" ] || [ -e /var/lib/dpkg/info/pulseaudio.list ]; then
        el_debug "PulseAudio audio server detected"
        pulseaudio -k 2>/dev/null || true
        pulseaudio -D
        LC_ALL=C sleep 2

        if ! pulseaudio --check 1>/dev/null 2>&1 ; then
            pulseaudio -k 2>/dev/null || true
            pulseaudio -D
        fi
        LC_ALL=C sleep 2

        if ! pactl info 1>/dev/null 2>&1 ; then
            if [ "${is_systemd:-0}" -ne 0 ]; then
                systemctl --user restart pulseaudio 2>/dev/null || pulseaudio -k 2>/dev/null || true
            elif [ "${is_openrc:-0}" -ne 0 ] || [ "${is_sysvinit:-0}" -ne 0 ]; then
                sudo service pulseaudio restart 2>/dev/null || true
            else
                pulseaudio -k 2>/dev/null || true
                pulseaudio -D
            fi
        fi
    elif [ "${is_alsa:-0}" -ne 0 ] || [ -x "$(which alsactl)" ]; then
        el_debug "ALSA audio detected"
        if [ "${is_systemd:-0}" -ne 0 ] || [ "${is_openrc:-0}" -ne 0 ] || [ "${is_sysvinit:-0}" -ne 0 ]; then
            sudo service alsa-utils restart 2>/dev/null || sudo alsactl restore 2>/dev/null || true
        else
            sudo alsactl restore 2>/dev/null || true
        fi
    fi

    if [ "${is_trixie:-0}" -ne 0 ]; then
        el_debug "Debian Trixie audio environment configured"
    fi
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
