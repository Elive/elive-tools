#!/bin/sh

main(){
    # pre {{{
    #local file dir temp

    if ! [ -s "/tmp/.lshal" ] || ! [ "$( wc -l "/tmp/.lshal" | cut -f 1 -d ' ' )" -gt 100 ] ; then
        if [ -x "/usr/sbin/hald" ] ; then
            timeout 20 /usr/sbin/hald
            #sync # do not enable sync here, at first boot time in installed seems like it bottlenecks a bit (flushing new FS datas?)
            LC_ALL=C sleep 1

            if ! timeout 20 lshal 2>/dev/null > /tmp/.lshal ; then
                timeout 30 lshal 2>/dev/null > /tmp/.lshal || true
            fi
            # save some memory
            killall hald 2>/dev/null 1>&2 || true
        fi
    fi

    # }}}

    # This is needed for the composite wizard page 150 modifications:
    if [ -s "/tmp/.lshal" ] ; then
        if grep -qsi "system.hardware.product =.*VirtualBox" /tmp/.lshal || grep -qsi "system.hardware.product =.*vmware" /tmp/.lshal || grep "QEMU" /tmp/.lshal | egrep -q "^\s+info.vendor" ;  then
            touch "/tmp/.virtualmachine-detected" 2>/dev/null
            chmod a+rw "/tmp/.virtualmachine-detected" 2>/dev/null
        fi
    else
        echo "W: hald not found, ignoring..." 1>&2
    fi
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
