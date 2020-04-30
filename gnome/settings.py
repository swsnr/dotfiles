#!/usr/bin/env python3
# Copyright 2020 Sebastian Wiesner <sebastian@swsnr.de>
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

import sys
import json
from pathlib import Path
from subprocess import run
from gi.repository import Gio


EXTENSIONS = {
    # User shell themes
    'user-theme@gnome-shell-extensions.gcampax.github.com',
    # Update notifications
    'arch-update@RaphaelRochet',
    # Basic desktop stuff
    'appindicatorsupport@rgcjonas.gmail.com',
    # NASA wallpapers
    'nasa_apod@elinvention.ovh',
    # Search providers I use often
    'vscode-search-provider@jomik.org',
}


SETTINGS = {
    'org.gnome.desktop.interface': {
        # Theme
        'gtk-theme': 'Yaru',
        'icon-theme': 'Yaru',
        'cursor-theme': 'Yaru',
        # Fonts
        'font-name': 'Ubuntu 12',
        'document-font-name': 'Ubuntu 12',
        'monospace-font-name': 'Ubuntu Mono 11',
        # Disable hot corner for mouse
        'enable-hot-corners': False,
        # Show date and weekday in clock
        'clock-show-date': True,
        'clock-show-weekday': True,
        # Press left control to locate the cursoer
        'locate-pointer': True,
    },
    'org.gnome.mutter': {
        # Extend workspace across all screens
        'workspaces-only-on-primary': False,
    },
    'org.gnome.shell.app-switcher': {
        # Limit app and window switcher to current workspace
        'current-workspace-only': True
    },
    'org.gnome.system.location': {
        # Enable location service
        'enabled': True,
    },
    'org.gnome.desktop.peripherals.keyboard': {
        'remember-numlock-state': False,
        'numlock-state': True
    },
    'com.gexperts.Tilix.Settings': {
        # Include terminal title in window title
        'app-title':  '${appName}: ${activeTerminalTitle}',
        # Quit tilix when the last session closes
        'close-with-last-session': True,
        # Dont' warn about VTE configuration; fish already takes care of this.
        'warn-vte-config-issue': False
    },
    # Theme for the Gnome shell
    'org.gnome.shell.extensions.user-theme': {
        'name': 'Yaru'
    },
    # Commands for checking and performing Arch updates
    'org.gnome.shell.extensions.arch-update': {
        'check-cmd': "/usr/bin/sh -c 'checkupdates; aur repo -ud aur'",
        'update-cmd': "tilix -e 'sh -c  \"aur sync -cud aur && sudo pacman -Syu; echo Done - Press enter to exit; read\" '"
    }
}

TILIX_PROFILE = {
    'use-system-font': False,
    'font': 'PragmataPro Mono Liga 13',
    'terminal-bell': 'icon',
    'default-size-columns': 120,
    'default-size-rows': 40,
    # Don't mess with bold colors
    'bold-is-bright': False
}

TILIX_PROFILE_SCHEME = 'tango'

KEYBINDINGS = {
    'org.gnome.desktop.wm.keybindings': {
        'close': ['<Alt>F4', '<Super>F4'],
        # Replace app switching with window switching
        'switch-applications': [],
        'switch-applications-backward': [],
        'switch-windows': ['<Super>Tab', '<Alt>Tab'],
        'switch-windows-backward': ['<Shift><Super>Tab', '<Shift><Alt>Tab'],
        # Toggle fullscreen mode for apps
        'toggle-fullscreen': ['<Super>Return'],
        # Keep on top above all other windows
        'always-on-top': ['<Shift><Super>t'],
    }
}

CUSTOM_BINDINGS = {
    'ui-theme': {
        'name': 'Toggle UI Theme',
        'command': 'ui-theme toggle',
        'binding': '<Super>q',
    },
    'random-wallpaper': {
        'name': 'Set random wallpaper',
        'command': 'random-wallpaper',
        'binding': '<Super>w',
    },
    'tilix': {
        'name': 'New tilix window',
        'command': 'tilix',
        'binding': '<Super>t',
    }
}


def set_pytype(settings, key, value):
    if isinstance(value, str):
        settings.set_string(key, value)
    elif isinstance(value, bool):
        settings.set_boolean(key, value)
    elif isinstance(value, int):
        settings.set_int(key, value)
    elif isinstance(value, list):
        settings.set_strv(key, value)
    else:
        raise ValueError(f'Value {value!r} for key {key} has unknown type')


def _settings_for_key(key):
    if isinstance(key, str):
        schema_name = schema = key
        settings = Gio.Settings(schema=schema)
    else:
        schema, path = key
        schema_name = f'{schema}:{path}'
        settings = Gio.Settings.new_with_path(schema, path)
    return (schema_name, settings)


def apply_settings():
    for key, items in SETTINGS.items():
        name, settings = _settings_for_key(key)
        for key, value in items.items():
            print(f'{name} {key} {value}')
            set_pytype(settings, key, value)


def apply_keybindings():
    for schema, items in KEYBINDINGS.items():
        settings = Gio.Settings(schema=schema)
        for key, value in items.items():
            print(f'{schema} {key} {value}')
            settings.set_strv(key, value)


def apply_tilix_scheme_to_profile(profile_settings):
    scheme_file = Path(f"/usr/share/tilix/schemes/{TILIX_PROFILE_SCHEME}.json")
    scheme = json.loads(scheme_file.read_text())
    for key in ['use-theme-colors', 'background-color', 'background-color', 'palette']:
        value = scheme.get(key)
        if value:
            set_pytype(profile_settings, key, scheme[key])
        else:
            profile_settings.reset(key)


def apply_tilix_profile():
    tilix = Gio.Settings(schema='com.gexperts.Tilix.ProfilesList')
    profile_id = tilix.get_string('default')
    profile_path = f'/com/gexperts/Tilix/profiles/{profile_id}/'
    schema = 'com.gexperts.Tilix.Profile'
    profile = Gio.Settings.new_with_path(schema_id=schema, path=profile_path)
    for key,  value in TILIX_PROFILE.items():
        print(f'{schema}:{profile_path} {key} {value}')
        set_pytype(profile, key, value)
    apply_tilix_scheme_to_profile(profile)


def binding_path(id):
    return f'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/{id}/'


def apply_custom_bindings():
    schema = 'org.gnome.settings-daemon.plugins.media-keys.custom-keybinding'
    for id, settings in CUSTOM_BINDINGS.items():
        binding = Gio.Settings.new_with_path(schema_id=schema,
                                             path=binding_path(id))
        for key, value in settings.items():
            print(f'{schema}:{binding_path(id)} {key} {value}')
            binding.set_string(key, value)

    media_keys = Gio.Settings(
        schema='org.gnome.settings-daemon.plugins.media-keys')
    custom_bindings = set(media_keys.get_strv('custom-keybindings'))
    custom_bindings.update(binding_path(id) for id in CUSTOM_BINDINGS)
    media_keys.set_strv('custom-keybindings', list(custom_bindings))


def enable_extensions():
    available_extensions = set(run(['gnome-extensions', 'list'],
                                   check=True, capture_output=True,
                                   text=True).stdout.splitlines())
    for extension in EXTENSIONS:
        if extension not in available_extensions:
            print(f'Extension {extension} not installed!', file=sys.stderr)
        else:
            print(f'gnome-extensions enable {extension}')
            run(['gnome-extensions', 'enable', extension], check=True)


def main():
    apply_settings()
    apply_keybindings()
    apply_custom_bindings()
    apply_tilix_profile()
    enable_extensions()


if __name__ == '__main__':
    main()
