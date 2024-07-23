#!/bin/sh

main(){

    # update: not needed anymore?
    exit

    # if [ -x "$(which pulseaudio)" ] && [ -e /var/lib/dpkg/info/pulseaudio.list ] ; then
    #     pulseaudio -k 2>/dev/null || true
    #     pulseaudio -D
    #     LC_ALL=C sleep 2
    #
    #     if ! pulseaudio --check 1>/dev/null 2>&1 ; then
    #         pulseaudio -k 2>/dev/null || true
    #         pulseaudio -D
    #     fi
    #     LC_ALL=C sleep 2
    #
    #     if ! pactl info 1>/dev/null 2>&1 ; then
    #         pulseaudio -k 2>/dev/null || true
    #         pulseaudio -D
    #     fi
    # fi
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
