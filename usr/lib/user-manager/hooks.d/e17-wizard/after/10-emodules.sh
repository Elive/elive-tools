#!/bin/sh
main(){
    if [ -n "$EROOT" ] ; then
        # e16
        true
    else
        # e17
        if [ -n "$E_START" ] && [ -n "$( which enlightenment_remote )" ] ; then

            # disable battery emodule if the battery is broken
            # tested in: wheezy, buster
            # checks in order:
            # only 0/1/2% of battery remaining (broken values)
            # battery not working/detected
            # or we have no numeric values with % at all
            acpi_result="$( LC_ALL=C acpi 2>&1 )"
            if echo "$acpi_result" | grep -qsE "\s+(0|1|2)%" \
                || echo "$acpi_result" | grep -qsE "No support for.*power_supply" \
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
                mkdir -p "$HOME/.e/e17/applications/restart"
                if ! grep -qs "arandr-load-conf.desktop" "$HOME/.e/e17/applications/restart/.order" ; then
                    echo "arandr-load-conf.desktop" >> "$HOME/.e/e17/applications/restart/.order"
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

