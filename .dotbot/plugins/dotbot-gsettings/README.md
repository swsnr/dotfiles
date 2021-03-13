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
# Configure the default profile of Gnome Terminal
- gnome_terminal_profile:
    audible-bell: false
    default-size-columns: 120
    default-size-rows: 40
# Custom key bindings (use gsettings to change built-in bindings, see above)
- gnome_bindings:
    # Bind firefox to Super+c
    firefox:
      name: Start firefox
      command: firefox
      binding: <Super>f
    # Remove a previous binding with the ID "chrome"
    chrome:
      binding: false
```

[dotbot]: https://github.com/anishathalye/dotbot

## License

This Source Code Form is subject to the terms of the Mozilla Public License, v.
2.0. If a copy of the MPL was not distributed with this file, You can obtain one
at http://mozilla.org/MPL/2.0/.
