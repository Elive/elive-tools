#!/bin/bash
source /usr/lib/elive-tools/functions

demo_file_add_home(){
    local from target file subdir
    file="$1"
    target="$2"

    filename="$(basename "$file" )"
    from="${demodir}/${file}"
    subdir="${file%/*}"

    if [[ -L "$file" ]] ; then
        file="$(readlink -f "$file" )"
    fi
    if [[ -s "$file" ]] ; then
        el_warning "skipping $file, it seems to be empty or broken link"
        return
    fi


echo    mkdir -p "${target}/${subdir}"
echo    ln -s "$from" "$target/$subdir/$filename"

}

main(){
    # pre {{{
    local demodir target

    demodir="/usr/share/elive-demo-files-skel"

    if [[ ! -d "$demodir" ]] ; then
        el_warning "Demo files dir empty"
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
    fi

    target="$( xdg-user-dir DOCUMENTS )"
    while read -ru 3 file
    do
        demo_file_add_home "$file" "$target"
    done 3<<< "$( find "$demodir/Documents" \( -type f -o -type l \) | sed -e "s|^${demodir}/||g" )"


}

#
#  MAIN
#
main "$@"

# vim: set foldmethod=marker :
