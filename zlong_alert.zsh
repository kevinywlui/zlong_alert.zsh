# Use zsh/datetime for $EPOCHSECONDS
zmodload zsh/datetime || return

# Be sure we can actually set hooks
autoload -Uz add-zsh-hook || return

# Use notify-send if it exists and is not explicitly disabled
if ! [[ -x "$(command -v notify-send)" ]]; then
    zlong_use_notify_send='false'
fi
(( ${+zlong_use_notify_send} )) || zlong_use_notify_send='true'

# Define a long duration if needed
(( ${+zlong_duration} )) || zlong_duration=15

# Set commands to ignore if needed
(( ${+zlong_ignore_cmds} )) || zlong_ignore_cmds='vim ssh'


# Need to set an initial timestamps otherwise, we'll be comparing an empty
# string with an integer.
zlong_timestamp=$EPOCHSECONDS

# Define the alerting function, do the text processing here
zlong_alert_func() {
    local cmd=$1
    local secs=$2
    local ftime=$(printf '%dh:%dm:%ds\n' $(($secs / 3600)) $(($secs % 3600 / 60)) $(($secs % 60)))
    if [[ "$zlong_use_notify_send" == true ]]; then
        notify-send "Done: $1" "Time: $ftime"
    fi
    echo -n "\a"
}

zlong_alert_pre() {
    zlong_timestamp=$EPOCHSECONDS
    zlong_last_cmd=$1
}

zlong_alert_post() {
    local duration=$(($EPOCHSECONDS - $zlong_timestamp))
    local lasted_long=$(($duration - $zlong_duration))
    local cmd_head=$(echo $zlong_last_cmd | cut -d ' ' -f 1)
    if [[ $lasted_long -gt 0 && ! -z $zlong_last_cmd && ! $zlong_ignore_cmds =~ $cmd_head ]]; then
        zlong_alert_func $zlong_last_cmd duration
    fi
    zlong_last_cmd=''
}

add-zsh-hook preexec zlong_alert_pre
add-zsh-hook precmd zlong_alert_post
