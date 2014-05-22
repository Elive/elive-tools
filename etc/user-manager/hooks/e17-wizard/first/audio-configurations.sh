#!/bin/bash
source /usr/lib/elive-tools/functions

main(){
    # pre {{{
    local  var

    # }}}

    el_explain 0 "Configuring audio cards..."
    audio-configurator --quiet

    el_explain 0 "Setting default volumes..."
    setvolume defaults

}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
