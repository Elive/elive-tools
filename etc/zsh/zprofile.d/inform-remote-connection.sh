#!/bin/zsh

if [ -n "$ZSH_VERSION" ] ; then
    zsh /usr/lib/elive-tools/hooks/shell/inform-remote-connection.sh  &|
fi

