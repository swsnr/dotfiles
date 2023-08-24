#!/usr/bin/python
# Copyright Sebastian Wiesner <sebastian@swsnr.de>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

# ruff: noqa: T201

"""My gnome settings."""

import sys
import json
from socket import gethostname
from pathlib import Path

from gi.repository import Gio, GLib

SETTINGS = {
    "org.gnome.mutter": {
        "dynamic-workspaces": True,
        # Only switch workspaces on primary screen, and treat secondary screens
        # as kind of permanent notepads.  Particularly useful to always have
        # a terminal at hand, and keep zim available
        "workspaces-only-on-primary": True,
    },

    # Power settings
    "org.gnome.settings-daemon.plugins.power": {
        # Suspend after 30 minutes of inactivity when on AC power
        "sleep-inactive-ac-timeout": 900,
        "sleep-inactive-ac-type": "suspend",
        # On battery suspend after five minutes already
        "sleep-inactive-battery-timeout": 300,
        "sleep-inactive-battery-type": "suspend",
    },

    # Night light
    "org.gnome.settings-daemon.plugins.color": {
        "night-light-enabled": True,
    },

    # System settings
    "org.gnome.system.location": {
        # Enable location service
        "enabled": True,
    },

    # Desktop settings
    "org.gnome.desktop.calendar": {
        # Show week numbers in calendar
        "show-weekdate": True,
    },
    "org.gnome.desktop.input-sources": {
        # compose:ralt: Set compose key to right alt key, for my moonlander layout
        # numpad:mac: Always use numpad for nummeric keys, never for arrows and stuff
        "xkb-options": ["compose:ralt", "numpad:mac"],
    },
    "org.gnome.desktop.interface": {
        # Themes and fonts
        "icon-theme": None,
        "gtk-theme": None,
        "font-name": None,
        "document-font-name": None,
        "monospace-font-name": None,
        # Disable hot corner
        "enable-hot-corners": False,
        # Show date and weekday in clock
        "clock-show-date": True,
        "clock-show-weekday": True,
        # Disable Ctrl shortcut for locating the cursor; conflicts with
        # IntelliJs Ctrl shortcut to add multiple cursors
        "locate-pointer": False,
    },
    "org.gnome.desktop.notifications": {
        # Do not show notifications in lock screen.  I find this noisy.
        "show-in-lock-screen": False,
    },
    "org.gnome.desktop.peripherals.keyboard": {
        "remember-numlock-state": True,
    },
    "org.gnome.desktop.media-handling": {
        # Never mount external disks automatically.
        "automount": False,
        "automount-open": False,
    },
    "org.gnome.desktop.screensaver": {
        # Lock screen immediately when the session becomes idle
        "lock-enabled": True,
        "lock-delay": GLib.Variant("u", 0),
    },
    "org.gnome.desktop.session": {
        # After five minutes the session becomes idle, and the timeouts for
        # power-saving and lock-screen start
        "idle-delay": GLib.Variant("u", 300),
    },

    # Window manager settings
    "org.gnome.desktop.wm.preferences": {
        "titlebar-font": None,
    },
    "org.gnome.desktop.wm.keybindings": {
        "close": ["<Super>q", "<Alt>F4"],
        # Switch windows not applications
        "switch-applications": [],
        "switch-applications-backward": [],
        "switch-group": [],
        "switch-group-backward": [],
        "switch-windows": ["<Super>Tab", "<Alt>Tab"],
        "switch-windows-backward": ["<Shift><Super>Tab", "<Shift><Alt>Tab"],
        # Keep on top above all other windows
        "always-on-top": ["<Shift><Super>t"],
        "toggle-on-all-workspaces": ["<Super>period"],
        # Disable input method switching wtih Super+Space
        "switch-input-source": ["XF86Keyboard"],
        "switch-input-source-backward": ["<Shift>XF86Keyboard"],
        # Toogle fullscreen
        "toggle-fullscreen": ["<Super>Return"],
        # Switch to and move workspaces
        "switch-to-workspace-1": ["<Super>1"],
        "switch-to-workspace-2": ["<Super>2"],
        "switch-to-workspace-3": ["<Super>3"],
        "switch-to-workspace-4": ["<Super>4"],
        "switch-to-workspace-5": ["<Super>5"],
        "switch-to-workspace-6": ["<Super>6"],
        "move-to-workspace-1": ["<Shift><Super>1"],
        "move-to-workspace-2": ["<Shift><Super>2"],
        "move-to-workspace-3": ["<Shift><Super>3"],
        "move-to-workspace-4": ["<Shift><Super>4"],
        "move-to-workspace-5": ["<Shift><Super>5"],
        "move-to-workspace-6": ["<Shift><Super>6"],
    },

    # Shell settings
    "org.gnome.shell.keybindings": {
        # Disable default shortcuts for application launchers (Super+<number>)
        # I prefer to have these for workspace switching
        "switch-to-application-1": [],
        "switch-to-application-2": [],
        "switch-to-application-3": [],
        "switch-to-application-4": [],
        "switch-to-application-5": [],
        "switch-to-application-6": [],
        "switch-to-application-7": [],
        "switch-to-application-8": [],
        "switch-to-application-9": [],
    },
    "org.gnome.shell.app-switcher": {
        # Limit app and window switcher to current workspace
        "current-workspace-only": True,
    },

    # Gtk settings
    "org.gtk.Settings.FileChooser": {
        "sort-directories-first": True,
    },
    "org.gtk.gtk4.Settings.FileChooser": {
        "sort-directories-first": True,
    },

    # Application settings
    "org.gnome.nautilus.icon-view": {
        # Show file size in captions
        "captions": ["size", "none", "none"],
    },
    "org.gnome.nautilus.list-view": {
        # Make folders expandable in list view
        "use-tree-view": True,
    },

    "org.gnome.evolution": {
       "disabled-eplugins": [
            # This is not the 90s anymore
            "org.gnome.evolution.plugin.preferPlain",
            # I don't use templates and custom headers
            "org.gnome.evolution.plugin.templates",
            "org.gnome.evolution.email-custom-header",
            # Don't manage my addressbook automatically
            "org.gnome.evolution.bbdb",
            # I don't publish my calendar
            "org.gnome.evolution.calendar.publish",
        ],
    },
    "org.gnome.evolution.shell": {
        # Keep the menubar visible; the standard actions are somewhat basic.
        "menubar-visible": True,
    },
    "org.gnome.evolution.calendar": {
        # Show timezone input when creating calender entries.  I often have
        # to make entries in UTC time, and it's simpler to directly select UTC.
        "editor-show-timezone": True,
        # Don't shorten appointments automatically
        "shorten-time": 0,
        # Proper time
        "use-24hour-format": True,
    },
    "org.gnome.evolution.plugin.attachment-reminder": {
        # Tune marker words for attachments (I write German and English).
        "attachment-reminder-clues": [
            "Anhang",
            "Anlage",
            "Beilage",
            "angehängt",
            "anhängen",
            "beigelegt",
            "beigefügt",
            "attachment",
            "attached",
        ],
    },

    "org.gnome.software": {
        # Don't educate me Gnome
        "show-nonfree-ui": False,
        "prompt-for-nonfree": False,
        # I'll handle this myself
        "enable-repos-dialog": False,
    },

    "org.gnome.Epiphany": {
        # Adjust search engines: Remove bing, and add startpage as default
        # search engine
        "default-search-engine": "Startpage",
        "search-engine-providers": GLib.Variant(
            "aa{sv}",
            [
                {
                    "url": GLib.Variant.new_string("https://www.startpage.com/sp/search?query=%s"),
                    "bang": GLib.Variant.new_string("!sp"),
                    "name": GLib.Variant.new_string("Startpage"),
                },
                {
                    "url": GLib.Variant.new_string("https://duckduckgo.com/?q=%s&t=epiphany"),
                    "bang": GLib.Variant.new_string("!ddg"),
                    "name": GLib.Variant.new_string("DuckDuckGo"),
                },
                {
                    "url": GLib.Variant.new_string("https://www.google.com/search?q=%s"),
                    "bang": GLib.Variant.new_string("!g"),
                    "name": GLib.Variant.new_string("Google"),
                },
            ],
        ),
        # Use a more comprehensive content filter list
        "content-filters": ["https://easylist-downloads.adblockplus.org/easylist_content_blocker.json"],
    },
    ("org.gnome.Epiphany.web", "/org/gnome/epiphany/web/"): {
        # Perhaps it's getting there one day (e.g. ublock origin, 1password)
        "enable-webextensions": True,
        # 1password does this
        "remember-passwords": False,
    },
}

EXTENSION_SETTINGS = {
    "dash-to-panel@jderose9.github.com": {
        "org.gnome.shell.extensions.dash-to-panel": {
            # Panel on the top, but on 32px high.  These are JSON values
            # actually, that's why we don't use GVariant here.
            "panel-positions": json.dumps({str(i): "TOP" for i in range(3)}),
            "panel-sizes": json.dumps({str(i): 32 for i in range(3)}),
            # Sync panel elements across all monitors
            "panel-element-positions-monitors-sync": True,
            "panel-element-positions": json.dumps({
                "0": [
                    {
                        "element": "showAppsButton",
                        "visible": True,
                        "position": "stackedTL",
                    },
                    {
                        "element": "activitiesButton",
                        "visible": False,
                        "position": "stackedTL",
                    },
                    {
                        "element": "leftBox",
                        "visible": True,
                        "position": "stackedTL",
                    },
                    {
                        "element": "taskbar",
                        "visible": True,
                        "position": "stackedTL",
                    },
                    {
                        "element": "centerBox",
                        "visible": True,
                        "position": "stackedTL",
                    },
                    {
                        "element": "rightBox",
                        "visible": True,
                        "position": "stackedBR",
                    },
                    {
                        "element": "dateMenu",
                        "visible": True,
                        "position": "stackedBR",
                    },
                    {
                        "element": "systemMenu",
                        "visible": True,
                        "position": "stackedBR",
                    },
                    {
                        "element": "desktopButton",
                        "visible": False,
                        "position": "stackedBR",
                    },
                ],
            }),
            # Isolate workspaces for running apps
            "isolate-workspaces": True,
            # Bling bling
            "animate-appicon-hover": True,
            # Activity indicator on top, because our panel is also on top
            "dot-position": "TOP",
            # Use a different indicator for unfocused apps, to set the focused
            # app apart from other icons.
            "dot-style-unfocused": "DASHES",
            # Prevent automatic overview mode on startup
            "hide-overview-on-startup": True,
            # Show panel on main screen only
            "multi-monitors": False,
        },
    },
}

TERMINAL_PROFILE = {
    "audible-bell": False,
    "bold-is-bright": False,
    "default-size-columns": 120,
    "default-size-rows": 40,
    "font": "JetBrains Mono 10",
    "use-system-font": False,
    "visible-name": "Shell",
    # Tango theme
    "palette": [
        "rgb(46,52,54)",
        "rgb(204,0,0)",
        "rgb(78,154,6)",
        "rgb(196,160,0)",
        "rgb(52,101,164)",
        "rgb(117,80,123)",
        "rgb(6,152,154)",
        "rgb(211,215,207)",
        "rgb(85,87,83)",
        "rgb(239,41,41)",
        "rgb(138,226,52)",
        "rgb(252,233,79)",
        "rgb(114,159,207)",
        "rgb(173,127,168)",
        "rgb(52,226,226)",
        "rgb(238,238,236)",
    ],
    "foreground-color": "#F8F8F2",
    "use-theme-colors": True,
    "use-custom-command": True,
    "custom-command": "systemd-run-fish",
}

BINDINGS = {
    "terminal": False,
    "toggle-theme": {
        "name": "Toggle UI theme",
        "command": "ui-theme toggle",
        "binding": "<Super>apostrophe",
    },
    "onepassword-quick": {
        "name": "1Password quick access",
        "command": "1password --quick-access",
        "binding": "<Super>o",
    },
    "onepassword-show": {
        "name": "Show 1password",
        "command": "1password --show",
        "binding": "<Super>p",
    },
}

# Override some settings for workstations
if "RB" in gethostname():
    SETTINGS["org.gnome.settings-daemon.plugins.power"] \
        ["sleep-inactive-ac-type"] = "nothing"


GlibValue = None | str | bool | int | list[str] | GLib.Variant


def set_pytype(settings: Gio.Settings, key: str, value: GlibValue) -> None:
    """Set `key` in `settings` to the given `value`."""
    if value is None:
        settings.reset(key)
    elif isinstance(value, GLib.Variant):
        settings.set_value(key, value)
    elif isinstance(value, str):
        settings.set_string(key, value)
    elif isinstance(value, bool):
        settings.set_boolean(key, value)
    elif isinstance(value, int):
        settings.set_int(key, value)
    elif isinstance(value, list):
        settings.set_strv(key, value)
    else:
        message = f"Value {value!r} for key {key} has unknown type"
        raise TypeError(message)


def set_all_items(settings: Gio.Settings, items: dict[str, GlibValue]) -> None:
    """Apply all `items` to `settings`."""
    settings_schema = settings.get_property("settings-schema")
    schema = settings.get_property("schema")
    for key, value in items.items():
        if settings_schema.has_key(key):
            print(f"{schema}.{key} = {value}")
            set_pytype(settings, key, value)
        else:
            print(f"{schema}.{key} does not exist!", file=sys.stderr)


def apply_settings() -> None:
    """Apply all standard settings."""
    default_source = Gio.SettingsSchemaSource.get_default()
    if not default_source:
        msg = "No default schema source found!"
        raise LookupError(msg)
    for schema_id_or_path, items in SETTINGS.items():
        if isinstance(schema_id_or_path, str):
            schema_id = schema_id_or_path
            path = None
        else:
            schema_id, path = schema_id_or_path
        schema = default_source.lookup(schema_id, False) # noqa: FBT003
        if schema:
            settings = Gio.Settings.new_full(schema=schema, backend=None,
                                             path=path)
            set_all_items(settings, items)
        else:
            print(f"Skipping non-existing schema {schema_id}", file=sys.stderr)


def apply_extension_settings() -> None:
    """Apply all settings for gnome extensions."""
    default_source = Gio.SettingsSchemaSource.get_default()
    if not default_source:
        msg = "No default schema source found!"
        raise LookupError(msg)
    extension_prefixes = [
        Path("/usr/share/gnome-shell/extensions"),
        Path.home() / "local" / "share" / "gnome-shell" / "extensions",
    ]
    for uuid, schemas in EXTENSION_SETTINGS.items():
        schema_dirs = (p / uuid / "schemas" for p in extension_prefixes)
        schema_dir = next((d for d in schema_dirs if d.exists()), None)
        if schema_dir:
            source = Gio.SettingsSchemaSource.new_from_directory(
                directory=str(schema_dir),
                parent=default_source,
                trusted=True,
            )
        else:
            # Some extensions get packaged to install their schemas into the
            # standard schema dir; that's somewhat unususal, but not a bad idea,
            # so let's support it.
            source = default_source
        for schema_id, items in schemas.items():
            schema = source.lookup(schema_id, False) # noqa: FBT003
            if schema:
                settings = Gio.Settings.new_full(schema=schema, backend=None,
                                                 path=None)
                set_all_items(settings, items)
            else:
                print(f"Schema {schema_id} does not exist; extension {uuid} "
                      "not installed?", file=sys.stderr)


def apply_keybindings() -> None:
    """Apply all keybindings."""
    default_source = Gio.SettingsSchemaSource.get_default()
    if not default_source:
        msg = "No default schema source found!"
        raise LookupError(msg)
    media_keys_schema = "org.gnome.settings-daemon.plugins.media-keys"
    media_keys_path = "/" + media_keys_schema.replace(".", "/")
    bindings_schema = f"{media_keys_schema}.custom-keybinding"
    if not default_source.lookup(bindings_schema, False): # noqa: FBT003
        print("Schema for custom keybindings not found, skipping", file=sys.stderr)
    else:
        new_bindings = []
        removed_bindings = []
        for binding_id, binding in BINDINGS.items():
            path = f"{media_keys_path}/custom-keybindings/{binding_id}/"
            settings = Gio.Settings.new_with_path(
                schema_id=bindings_schema, path=path)
            if not binding:
                schema = settings.get_property("settings-schema")
                for key in schema.list_keys():
                    settings.reset(key)
                print(f"binding {binding_id} removed")
                removed_bindings.append(path)
            else:
                settings.set_string("name", binding["name"])
                settings.set_string("command", binding["command"])
                settings.set_string("binding", binding["binding"])
                print("{id} {binding}: {name} ({command})".format(
                    id=binding_id, **binding))
                new_bindings.append(path)

        media_keys = Gio.Settings(schema=media_keys_schema)
        custom_bindings = media_keys.get_strv("custom-keybindings")
        custom_bindings.extend(p for p in new_bindings if p not in custom_bindings)
        for path in removed_bindings:
            if path in custom_bindings:
                custom_bindings.remove(path)
        media_keys.set_strv("custom-keybindings", custom_bindings)


def apply_gnome_terminal() -> None:
    """Apply gnome-terminal settings."""
    default_source = Gio.SettingsSchemaSource.get_default()
    if not default_source:
        msg = "No default schema source found!"
        raise LookupError(msg)
    schema_id = "org.gnome.Terminal.ProfilesList"
    if not default_source.lookup(schema_id, False): # noqa: FBT003
        print("Terminal profile list not available, skipping", file=sys.stderr)
    else:
        profiles_list = Gio.Settings(schema=schema_id)
        profile_id = profiles_list.get_string("default")
        schema_id = "org.gnome.Terminal.Legacy.Profile"
        path = f"/org/gnome/terminal/legacy/profiles:/:{profile_id}/"
        settings = Gio.Settings.new_with_path(schema_id=schema_id, path=path)
        set_all_items(settings, TERMINAL_PROFILE)


def main() -> None:
    """Run this program."""
    apply_settings()
    apply_extension_settings()
    apply_keybindings()
    apply_gnome_terminal()


if __name__ == "__main__":
    main()
