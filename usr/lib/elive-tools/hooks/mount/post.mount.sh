#!/bin/bash
#source /usr/lib/elive-tools/functions

main(){
    # pre {{{
    local filesystem mountpoint partition label arg

    label="$1"
    partition="$2"
    mountpoint="$3"
    filesystem="$4"

    # temporal code in case thunar is not returning correctly the values (they shoudl be fixed in thunar and not from here)
    #for arg in "$@"
    #do
        #case "$arg" in
            #"/dev/"*)
                #partition="$arg"
                #shift
                #;;
            #"/media/"*|"/mnt/"*)
                #mountpoint="$arg"
                #shift
                #;;
            #fuse|ext*|reiser*|*fat*|btrfs|xfs|tmpfs|sysfs|proc|devtmpfs|debugfs|ramfs|devpts|autofs|fuseblk|fusectl|bfs|crypto|ecryptfs|efivarfs|f2fs|fat|hfs|hfsplus|isofs|jbd2|jffs2|jfs|nfs|romfs|squashfs|udf|ufs)
                #filesystem="$arg"
                #shift
                #;;
            #*)
                #label="$arg"
                #shift
                #;;
        #esac
    #done

    # }}}
    if [[ -b "/dev/disk/by-uuid/$partition" ]] ; then
        dev="/dev/disk/by-uuid/$partition"
    else
        if [[ -b "/dev/disk/by-label/$partition" ]] ; then
            dev="/dev/disk/by-label/$partition"
        fi
    fi

    if [[ "$filesystem" = "fuse" ]] && [[ -n "$dev" ]] && [[ -b "$dev" ]] ; then
        if partitions-list --show-only="$dev" | grep -qsi "::ntfs" ; then
            is_ntfs=1
        fi
    fi

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


    exit 0
}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
