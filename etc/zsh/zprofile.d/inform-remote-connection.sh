#!/bin/zsh

if [ -n "$ZSH_VERSION" ] ; then
    /usr/lib/elive-tools/hooks/shell/inform-remote-connection.sh  &|
fi

