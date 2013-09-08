#!/bin/bash
#source /usr/lib/elive-tools/functions

main(){
    # pre {{{
    local filesystem mountpoint partition label

    label="$1"
    partition="$2"
    mountpoint="$3"
    filesystem="$4"

    # }}}


    if [[ "$filesystem" = ntfs* ]] || [[ "${filesystem}" = NTFS* ]] ; then
	is_ntfs=1
    else
	if [[ -z "${filesystem}" ]] || [[ "$filesystem" = fuse* ]] ; then
	    if file -s "${partition}" | grep -isq "ntfs" ; then
		is_ntfs=1
	    fi

	fi
    fi


    if ((is_ntfs)) ; then
	warning-messages-elive ntfs_is_crap
    fi


}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
