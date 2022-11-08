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

# Set as true to enable terminal bell (beep)
(( ${+zlong_terminal_bell} )) || zlong_terminal_bell='true'

# Define a long duration if needed
(( ${+zlong_duration} )) || zlong_duration=15

# Set commands to ignore if needed
(( ${+zlong_ignore_cmds} )) || zlong_ignore_cmds='vim ssh'

# Set prefixes to ignore if needed
(( ${+zlong_ignore_pfxs} )) || zlong_ignore_pfxs='sudo time'

# Set as true to ignore commands starting with a space
(( ${+zlong_ignorespace} )) || zlong_ignorespace='false'

# Define a custom message to display
(( ${+zlong_message} )) || zlong_message='"Done: $cmd Time: $ftime"'

# Need to set an initial timestamps otherwise, we'll be comparing an empty
# string with an integer.
zlong_timestamp=$EPOCHSECONDS

# Define the alerting function, do the text processing here
zlong_alert_func() {
    local cmd=$1
    local secs=$2
    local ftime=$(printf '%dh:%dm:%ds\n' $(($secs / 3600)) $(($secs % 3600 / 60)) $(($secs % 60)))
    if [[ "$zlong_internal_send_notifications" != false ]]; then
        # Find and use the correct notification command based on OS name
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	    eval notify-send $zlong_message
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            (alerter -timeout 3 -message $zlong_message &>/dev/null &)
        fi
    fi

    if [[ "$zlong_terminal_bell" == 'true' ]]; then
	echo -n "\a"
    fi
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

    # Remove leading space(s), not useful anymore
    while [[ ${zlong_last_cmd:0:1} == [[:space:]] ]]; do
	zlong_last_cmd="${zlong_last_cmd:1}"
    done
}

zlong_alert_post() {
    local duration=$(($EPOCHSECONDS - $zlong_timestamp))
    local lasted_long=$(($duration - $zlong_duration))
    local cmd_head

    # Ignore command prefixes (like time and sudo)
    # and then consider command in argument
    local zlong_last_cmd_no_pfx="$zlong_last_cmd"
    local no_pfx
    while [[ -n "$zlong_last_cmd_no_pfx" && -z "$no_pfx" ]]; do
 	cmd_head="${zlong_last_cmd_no_pfx%% *}"
	if [[ $zlong_ignore_pfxs =~ (^|[[:space:]])${cmd_head}([[:space:]]|$) ]]; then
	    zlong_last_cmd_no_pfx="${zlong_last_cmd_no_pfx#* }"
	else
	    no_pfx=true
	fi
    done

    # Notify only if delay > $zlong_duration and command not ignored
    if [[ $lasted_long -gt 0 && ! -z $zlong_last_cmd_no_pfx && ! "$zlong_ignore_cmds" =~ (^|[[:space:]])${cmd_head}([[:space:]]|$) ]]; then
        zlong_alert_func "$zlong_last_cmd" duration
    fi
    zlong_last_cmd=''
}

add-zsh-hook preexec zlong_alert_pre
add-zsh-hook precmd zlong_alert_post
