# Use zsh/datetime for $EPOCHSECONDS
zmodload zsh/datetime || return

# Be sure we can actually set hooks
autoload -Uz add-zsh-hook || return

# Use value of zlong_use_notify_send if defined
(( ${+zlong_use_notify_send} )) && zlong_internal_send_notifications=$zlong_use_notify_send

# Use value of zlong_send_notifications if defined - This takes precedence over zlong_use_notify_send
(( ${+zlong_send_notifications} )) && zlong_internal_send_notifications=$zlong_send_notifications

# Disable notifications if both alerter and notify-send don't exist
if ! ([[ -x "$(command -v notify-send)" ]] || [[ -x "$(command -v alerter)" ]]); then
    zlong_internal_send_notifications='false'
fi

# Define a long duration if needed
(( ${+zlong_duration} )) || zlong_duration=15

# Set commands to ignore if needed
(( ${+zlong_ignore_cmds} )) || zlong_ignore_cmds='vim ssh'

# Set as true to ignore commands starting with a space
(( ${+zlong_ignorespace} )) || zlong_ignorespace='false'


# Need to set an initial timestamps otherwise, we'll be comparing an empty
# string with an integer.
zlong_timestamp=$EPOCHSECONDS

# Define the alerting function, do the text processing here
zlong_alert_func() {
    local cmd=$1
    local secs=$2
    local ftime=$(printf '%dh:%dm:%ds\n' $(($secs / 3600)) $(($secs % 3600 / 60)) $(($secs % 60)))
    local message="Done: $1 Time: $ftime"
    if [[ "$zlong_internal_send_notifications" != false ]]; then
        # Find and use the correct notification command based on OS name
        if [[ "${uname}" == "Linux" ]]
        then
            notify-send $message
        else
            (alerter -timeout 3 -message $message &>/dev/null &)
        fi
    fi
    echo -n "\a"
}

zlong_alert_pre() {
    zlong_last_cmd=$1

    if [[ $zlong_ignorespace == 'true' && ${zlong_last_cmd:0:1} == [[:space:]] ]]; then
        # set internal variables to nothing ignoring this command
        zlong_last_cmd=''
        zlong_timestamp=0
    else
        zlong_timestamp=$EPOCHSECONDS
    fi

}

zlong_alert_post() {
    local duration=$(($EPOCHSECONDS - $zlong_timestamp))
    local lasted_long=$(($duration - $zlong_duration))
    local cmd_head=$(echo $zlong_last_cmd | awk '{printf $1}')
    if [[ $lasted_long -gt 0 && ! -z $zlong_last_cmd && ! $zlong_ignore_cmds =~ $cmd_head ]]; then
        zlong_alert_func $zlong_last_cmd duration
    fi
    zlong_last_cmd=''
}

add-zsh-hook preexec zlong_alert_pre
add-zsh-hook precmd zlong_alert_post
