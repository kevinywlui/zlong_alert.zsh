# zlong_alert.zsh

`zlong_alert.zsh` will send a desktop notification and sound a
[bell](https://en.wikipedia.org/wiki/Bell_character) to alert you when a
command that has taken a long time (default: 15 seconds) has completed.

Desktop notifications are sent using `notify-send` on Linux and using [`alerter`](https://github.com/vjeantet/alerter) on MacOS.

---

## Installation

### Pre-requisite for MacOS only

Ensure that you downloaded the alerter binary from [here](https://github.com/vjeantet/alerter/releases), have placed it in your PATH, and given the file executable permissions before continuing with any of the installation methods.

### zplug

```bash
zplug "kevinywlui/zlong_alert.zsh"
```

### Oh My Zsh

1. Clone into `$ZSH_CUSTOM/plugins/zlong_alert`.
2. Add `zlong_alert` to `plugins` in `.zshrc`.

### Manual

This script just needs to be sourced so add this to your `.zshrc`:
```bash
source /path/to/zlong_alert.zsh
```

---

## Configuration

There are 4 variables you can set that will alter the behavior this script.

- `zlong_duration` (default: `15`): number of seconds that is considered a long duration.
- `zlong_ignore_cmds` (default: `"vim ssh"`): commands to ignore.
- `zlong_send_notifications` (default: `true`): whether to send notifications.
- `zlong_ignorespace` (default: `false`): whether to ignore commands with a leading space
- `zlong_message` (default: `'"Done: $cmd Time: $ftime"'`): define a custom message to display

For example, adding the following anywhere in your `.zshrc`
```bash
zlong_send_notifications=false
zlong_duration=2
zlong_ignore_cmds="vim ssh pacman yay"
```
will alert you, without sending a notification, if a command has lasted for more
than 2 seconds, provided that the command does not start with any of `vim ssh
pacman yay`.

### zlong_message

`zlong_message` will be expanded in to individual arguments to be passed to the alert command. The arguments must be wrapped in single quotes so not to evaluate the variables to early.

Currently, the variables `$cmd` and `$ftime` are available to be included in your `zlong_message` definition.

Note for linux:
`notify-send` allows both a heading and a body to be passed but will throw an error on a third argument (Invalid number of options.). Examples of how to do so are below:

```bash
# just a body
zlong_message='"Done: $cmd Time: $ftime"'
# a header and body
zlong_message='"Finished ($ftime)" "$cmd"'
```

## Changelog

See [CHANGELOG](./CHANGELOG.md)

## Credit

This script is the result of me trying to understand and emulate this gist:
<https://gist.github.com/jpouellet/5278239> My version fixes some things
(possibly bugs?) that I did not like about the original version.
