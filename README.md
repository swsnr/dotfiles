# dotbot-gsettings

A [dotbot] plugin to set Gnome settings.

```yaml
- gsettings:
    org.gnome.desktop.interface:
      enable-hot-corners: false
    org.gnome.desktop.wm.keybindings:
      switch-applications: []
      switch-applications-backward: []
      switch-windows: ['<Super>Tab', '<Alt>Tab']
      switch-windows-backward: ['<Shift><Super>Tab', '<Shift><Alt>Tab']
- gnome_terminal_profile:
    audible-bell: false
    default-size-columns: 120
    default-size-rows: 40
```

`gnome_terminal_profile` changes settings of the default Gnome Terminal profile.

## License

This Source Code Form is subject to the terms of the Mozilla Public License, v.
2.0. If a copy of the MPL was not distributed with this file, You can obtain one
at http://mozilla.org/MPL/2.0/.
