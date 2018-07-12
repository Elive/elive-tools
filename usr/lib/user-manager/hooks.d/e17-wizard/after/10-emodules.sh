#!/bin/bash
main(){
    # pre {{{

    # }}}

    # disable battery emodule if the battery is broken
    # checks:
    # only 0/1/2% of battery remaining (broken values)
    # battery not working/detected
    # or we have no numeric values with % at all
    if LC_ALL=C acpi 2>&1 | grep -qsE "\s+(0|1|2)%" \
        || LC_ALL=C acpi 2>&1 | grep -qsE "No support for.*power_supply" \
        || ! LC_ALL=C acpi 2>&1 | grep -qsE "\s+[[:digit:]]*%" ; then

        enlightenment_remote -module-disable battery
        enlightenment_remote -module-unload battery
    else
        enlightenment_remote -module-load battery
        enlightenment_remote -module-enable battery
    fi


    # save
    sync ; sleep 1
    enlightenment_remote -save


    # if we are debugging give it a little pause to see what is going on
    if grep -qs "debug" /proc/cmdline ; then
        echo -e "debug: sleep 2" 1>&2
    fi
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :

