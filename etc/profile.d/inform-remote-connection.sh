#!/bin/bash

# This tool informs to the user if somebody connected via ssh remotely from another country, comment/remove it if you found it annoying
if [ -n "$BASH_VERSION" ] ; then
    { bash /usr/lib/elive-tools/hooks/shell/inform-remote-connection.sh & disown ; } 2>/dev/null
fi
