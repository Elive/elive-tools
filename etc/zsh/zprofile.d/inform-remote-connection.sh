# which remote ip?
if [[ -n "$SSH_CLIENT" ]] ; then
    SSH_REMOTE_IP="${SSH_CLIENT%% *}"
fi
if [[ -z "$SSH_REMOTE_IP" ]] && [[ -n "$SSH_IP" ]] ; then
    SSH_REMOTE_IP="${SSH_IP%% *}"
fi

if [[ -z "$SSH_REMOTE_IP" ]] && [[ -n "$SSH2_IP" ]] ; then
    SSH_REMOTE_IP="${SSH2_IP%% *}"
fi


# For test, you can try to set this ip which should reference to India
#SSH_REMOTE_IP=14.139.237.50

if [[ -n "$SSH_REMOTE_IP" ]] ; then
    # set a lock here, just because sometimes we are logged in recursive mode and so we only want to run this one time
    LOCKFILE="/tmp/.inform-ssh-remote-${USER}-$(basename $0).lock"
    [[ -r $LOCKFILE ]] && PROCESS=$(cat $LOCKFILE) || PROCESS=" "
    if (ps -p $PROCESS) >/dev/null 2>&1
    then
        # already running
        return
    else
        rm -f $LOCKFILE
        echo $$ > $LOCKFILE
    fi

    # skip local connections, we don't want to inform about them
    if [[ "$SSH_REMOTE_IP" = "192.168."* ]] || [[ "$SSH_REMOTE_IP" = "10."* ]] ; then
        return
    fi
    if dpkg --compare-versions "$SSH_REMOTE_IP" ge "172.16" && dpkg --compare-versions "$SSH_REMOTE_IP" le "172.32" ; then
        return
    fi

    #echo -e "collecting remote data..." 1>&2
    if [[ -s "/tmp/.ssh_remote_data-${USER}:${SSH_REMOTE_IP}" ]] ; then
        SSH_REMOTE_DATA="$( cat "/tmp/.ssh_remote_data-${USER}:${SSH_REMOTE_IP}" )"
    else
        SSH_REMOTE_DATA="$( showmylocation "$SSH_REMOTE_IP" )"
        echo "$SSH_REMOTE_DATA" > "/tmp/.ssh_remote_data-${USER}:${SSH_REMOTE_IP}"
    fi

    # get the rest of data
    SSH_REMOTE_COUNTRY="$( echo "$SSH_REMOTE_DATA" | grep CountryName | sed -e 's|</Country.*$||g' -e 's|^.*Name>||g' )"
    SSH_REMOTE_REGION="$( echo "$SSH_REMOTE_DATA" | grep RegionName | sed -e 's|</Region.*$||g' -e 's|^.*Name>||g' )"
    SSH_REMOTE_CITY="$( echo "$SSH_REMOTE_DATA" | grep City | sed -e 's|</City.*$||g' -e 's|^.*City>||g' )"

fi

if [[ -n "$SSH_REMOTE_DATA" ]] ; then
    # get local data
    #echo -e "collecting local data..." 1>&2
    if [[ -s "/tmp/.ssh_local_data-${USER}" ]] ; then
        SSH_LOCAL_DATA="$( cat "/tmp/.ssh_local_data-${USER}" )"
    else
        SSH_LOCAL_DATA="$( showmylocation )"
        echo "$SSH_LOCAL_DATA" > "/tmp/.ssh_local_data-${USER}"
    fi

    # get the rest of data
    SSH_LOCAL_COUNTRY="$( echo "$SSH_LOCAL_DATA" | grep CountryName | sed -e 's|</Country.*$||g' -e 's|^.*Name>||g' )"
    SSH_LOCAL_REGION="$( echo "$SSH_LOCAL_DATA" | grep RegionName | sed -e 's|</Region.*$||g' -e 's|^.*Name>||g' )"
    SSH_LOCAL_CITY="$( echo "$SSH_LOCAL_DATA" | grep City | sed -e 's|</City.*$||g' -e 's|^.*City>||g' )"


    # Inform to user about remote connection from...
    if [[ "${SSH_REMOTE_COUNTRY}" != "$SSH_LOCAL_COUNTRY" ]] ; then
        el_speak_text "somebody connected from $SSH_REMOTE_COUNTRY"
        # wait a small delay for settle the lockfile in slow computers
        LC_NUMERIC=C sleep 0.8
    else
        if [[ "${SSH_REMOTE_REGION}" != "$SSH_LOCAL_REGION" ]] ; then
            el_speak_text "somebody connected from $SSH_REMOTE_REGION"
            LC_NUMERIC=C sleep 0.8
        else
            if [[ "${SSH_REMOTE_CITY}" != "$SSH_LOCAL_CITY" ]] ; then
                el_speak_text "somebody connected from $SSH_REMOTE_CITY"
                LC_NUMERIC=C sleep 0.8
            fi
        fi
    fi
fi
