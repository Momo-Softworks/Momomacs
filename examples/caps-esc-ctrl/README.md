# Caps Lock: tap for Esc, hold for Ctrl

Optional and system-wide, so the installer leaves it alone. It suits Meow
(Esc) and Emacs chords (Ctrl) without moving your hands.

## Windows

`caps-esc-ctrl.ahk` does it with AutoHotkey v2. A tap is a press and
release within 300 ms with no other key in between; holding Caps Lock
with another key gives Ctrl. Real Caps Lock is always off.

```powershell
winget install --id AutoHotkey.AutoHotkey --exact --scope machine
```

Copy the script somewhere outside `%APPDATA%`, then add a shortcut to it
in the Startup folder (`Win+R`, `shell:startup`) so it runs at login.
Point the shortcut at `C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe`
with the script's path as its argument: the UIA build also works in
windows running as administrator.

It runs as a login item, not a service, because services can't see the
keyboard of your desktop session.

## Linux and GNU Guix

Use [keyd](https://github.com/rvaiya/keyd), which works on X11, Wayland
and the console. In `/etc/keyd/default.conf`:

```ini
[ids]
*

[main]
capslock = overload(control, esc)
```

Then `sudo systemctl enable --now keyd`; on Guix System, start `keyd`
from a Shepherd system service instead. `interception-tools` with its
`caps2esc` plugin is an alternative.
