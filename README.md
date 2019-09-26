# zlong_alert.zsh

`zlong_alert.zsh` will use `notify-send` and a
[bell](https://en.wikipedia.org/wiki/Bell_character) to alert you when a
command that has taken a long time (default: 15 seconds) has completed.

---

## Installation

### zplug

```bash
zplug "kevinywlui/zlong_alert.zsh"
```

### Manual 

This script just needs to be sourced so add this to your `.zshrc`:
```bash
source /path/to/zlong_alert.zsh
```

---

## Configuration

There are 2 variables you can set that will alter the behavior this script.

- `zlong_duration` (default: `15`): number of seconds that is considered a long duration.
- `zlong_ignore_cmds` (default: `"vim ssh"`): commands to ignore.

For example, adding the following anywhere in your `.zshrc`
```bash
zlong_duration=2
zlong_ignore_cmds="vim ssh pacman yay"
```
will alert you if a command has lasted for more than 2 seconds, provided that
the command does not start with any of `vim ssh pacman yay`.

## Changelog

See [CHANGELOG](./CHANGELOG)

## Credit

This script is the result of me trying to understand and emulate this gist:
<https://gist.github.com/jpouellet/5278239> My version fixes some things
(possibly bugs?) that I did not like about the original version.
