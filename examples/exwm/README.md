# EXWM session integration

These are the out-of-repo bits that let a display manager (e.g. GDM) start
Emacs as an X window manager. The Emacs side is already wired in this repo:
`init.el` only loads the `exwm` module and calls `(exwm-enable)` when the
`EXWM_LAUNCH` environment variable is set, so a normal Emacs — and the
`emacs --fg-daemon` user service — never try to become the WM.

## Install

```sh
# 1. Launcher script
install -Dm755 examples/exwm/start-exwm ~/.local/bin/start-exwm

# 2. Display-manager session entry (GDM reads ~/.local/share/xsessions/)
mkdir -p ~/.local/share/xsessions
sed "s|/home/USER|$HOME|" examples/exwm/exwm.desktop \
    > ~/.local/share/xsessions/exwm.desktop
```

Then log out and pick **EXWM** from the session menu on the login screen.

> Note: `.desktop` `Exec=` does not expand `~` or `$HOME`, so it must be an
> absolute path — hence the `sed` substitution above.

## Customise

- **Monitors:** edit `momo-xrandr-command` and `exwm-randr-workspace-monitor-plist`
  in `config/exwm-config.el` to match `xrandr -q` (output names, modes, layout).
- **Auxiliary daemons:** run things like `picom`, `safeeyes`, etc. as
  `systemd --user` units with `PartOf=graphical-session.target` /
  `WantedBy=graphical-session.target`; `start-exwm` imports the X environment and
  starts that target for you.

## Notes

- Don't run EXWM under the Emacs daemon — EXWM must own the X display in the
  foreground process. Disable autostart with
  `systemctl --user disable emacs.service` if you only want one Emacs.
