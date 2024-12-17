#!/bin/sh
main(){
    # debug mode
    # if grep -Fqs "debug" /proc/cmdline ; then
    #     export EL_DEBUG=3
    #     if grep -Fqs "completedebug" /proc/cmdline ; then
    #         set -x
    #     fi
    # fi

    if [ -n "$EROOT" ] ; then
        # e16
        true
    else
        # enlightenment
        if [ -n "$E_START" ] && [ -z "$E_HOME_DIR" ] ; then
            E_HOME_DIR="$HOME/.e/e17"
        fi

        if [ -n "$E_START" ] && [ -n "$( which enlightenment_remote )" ] ; then

            # disable battery emodule if the battery is broken
            # tested in: wheezy, buster
            # checks in order:
            # only 0/1/2% of battery remaining (broken values)
            # battery not working/detected
            # or we have no numeric values with % at all
            acpi_result="$( LC_ALL=C acpi 2>&1 )"
            if echo "$acpi_result" | grep -qsE "\s+(0|1|2)%" \
                || echo "$acpi_result" | grep -qs "No support for.*power_supply" \
                || ! echo "$acpi_result" | grep -qsE "\s+[[:digit:]]*%" ; then

                enlightenment_remote -module-disable battery
                enlightenment_remote -module-unload battery
            else
                # enable battery by default
                enlightenment_remote -module-load battery
                enlightenment_remote -module-enable battery
            fi

            # always load screen configurations
            if [ -e "/usr/share/xdgeldsk/applications/arandr-load-conf.desktop" ] ; then
                mkdir -p "$E_HOME_DIR/applications/restart"
                if ! grep -Fqs "arandr-load-conf.desktop" "$E_HOME_DIR/applications/restart/.order" ; then
                    echo "arandr-load-conf.desktop" >> "$E_HOME_DIR/applications/restart/.order"
                fi
            fi


            # save
            sync ; sleep 1
            enlightenment_remote -save
        fi
    fi
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :

