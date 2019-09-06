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

## Credit

This script is the result of me trying to understand and emulate this gist:
<https://gist.github.com/jpouellet/5278239>
