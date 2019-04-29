#!/bin/bash
source /usr/lib/elive-tools/functions

demo_file_add_home(){
    local from target file subdir mode
    file="$1"
    target="$2"
    mode="$3"

    # make sure that we have a correct input
    if [[ -z "$file" ]] || [[ -z "$target" ]] || [[ "$file" != */* ]] ; then
        return
    fi

    # get some specific data
    filename="$(basename "$file" )"

    # absolute location of file
    from="${demodir}/${file}"

    # remove first subdir, which always we have it
    subdir="${file#*/}"

    # if we are a dir, just create it
    if [[ -d "$from" ]] ; then
        mkdir -p "$target/$subdir"
        return
    fi


    # fix paths from
    if [[ -L "$from" ]] ; then
        from="$(readlink -f "$from" )"
    fi
    if [[ ! -s "$from" ]] ; then
        el_warning "skipping $file, it seems to be empty or broken link"
        return
    fi


    case "$mode" in
        cp|copy)
            if [[ "$subdir" = */* ]] ; then
                # subdir to create if needed
                subdir="$( dirname "${subdir}" )"

                mkdir -p "${target}/${subdir}"
                cp "$from" "$target/$subdir"
            else
                cp "$from" "$target/"
            fi

            ;;
        ln|link|*)
            if [[ "$subdir" = */* ]] ; then
                # subdir to create if needed
                subdir="$( dirname "${subdir}" )"

                mkdir -p "${target}/${subdir}"
                ln -f -s "$from" "$target/$subdir"
            else
                ln -f -s "$from" "$target/"
            fi

            ;;
    esac


}

main(){
    # pre {{{
    local demodir target

    demodir="/usr/share/elive-demo-files-skel"

    # user can have the dir empty because selected to remove the files from the install
    if [[ ! -d "$demodir" ]] ; then
        el_debug "Demo files dir empty"
        exit
    fi

    # }}}

    # source after to have created it
    if [[ -z "${XDG_CONFIG_HOME}" ]] || [[ ! -d "$XDG_CONFIG_HOME" ]] ; then
        XDG_CONFIG_HOME="${HOME}/.config"
    fi
    if [[ -s "${XDG_CONFIG_HOME}/user-dirs.dirs" ]] ; then
        source "${XDG_CONFIG_HOME}/user-dirs.dirs"
    else
        el_error "No xdg dirs are set?"
        exit
    fi

    # check
    if [[ -z "$LANG" ]] || ! echo "$LANG" | grep -qsE "\.(UTF-8|utf8)" ; then
        el_warning "wrong language set? LANG is '$LANG', and /etc/default/locale set to '$(cat /etc/default/locale)' "
    fi


    # link all the files found:
    target="$( xdg-user-dir DOWNLOAD )"
    if [[ -n "$target" ]] ; then
        while read -ru 3 file
        do
            demo_file_add_home "$file" "$target" "link"
        done 3<<< "$( find "$demodir/Downloads" | sed -e "s|^${demodir}/||g" )"
    else
        el_warning "empty result for: xdg-user-dir DOWNLOAD"
    fi

    target="$( xdg-user-dir PUBLICSHARE )"
    if [[ -n "$target" ]] ; then
        while read -ru 3 file
        do
            demo_file_add_home "$file" "$target" "copy"
        done 3<<< "$( find "$demodir/Public" | sed -e "s|^${demodir}/||g" )"
    else
        el_warning "empty result for: xdg-user-dir PUBLICSHARE"
    fi

    target="$( xdg-user-dir DOCUMENTS )"
    if [[ -n "$target" ]] ; then
        while read -ru 3 file
        do
            demo_file_add_home "$file" "$target" "link"
        done 3<<< "$( find "$demodir/Documents" | sed -e "s|^${demodir}/||g" )"
    else
        el_warning "empty result for: xdg-user-dir DOCUMENTS"
    fi

    target="$( xdg-user-dir TEMPLATES )"
    if [[ -n "$target" ]] ; then
        while read -ru 3 file
        do
            demo_file_add_home "$file" "$target" "link"
        done 3<<< "$( find "$demodir/Templates" | sed -e "s|^${demodir}/||g" )"
    else
        el_warning "empty result for: xdg-user-dir TEMPLATES"
    fi

    target="$( xdg-user-dir MUSIC )"
    if [[ -n "$target" ]] ; then
        while read -ru 3 file
        do
            demo_file_add_home "$file" "$target" "link"
        done 3<<< "$( find "$demodir/Music" | sed -e "s|^${demodir}/||g" )"
    else
        el_warning "empty result for: xdg-user-dir MUSIC"
    fi

    target="$( xdg-user-dir PICTURES )"
    if [[ -n "$target" ]] ; then
        while read -ru 3 file
        do
            demo_file_add_home "$file" "$target" "link"
        done 3<<< "$( find "$demodir/Images" | sed -e "s|^${demodir}/||g" )"
    else
        el_warning "empty result for: xdg-user-dir PICTURES"
    fi

    target="$( xdg-user-dir VIDEOS )"
    if [[ -n "$target" ]] ; then
        while read -ru 3 file
        do
            demo_file_add_home "$file" "$target" "link"
        done 3<<< "$( find "$demodir/Videos" | sed -e "s|^${demodir}/||g" )"
    else
        el_warning "empty result for: xdg-user-dir VIDEOS"
    fi


    # if we are debugging give it a little pause to see what is going on
    if grep -qs "debug" /proc/cmdline ; then
        echo -e "debug: sleep 4" 1>&2
        sleep 4
    fi

}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
