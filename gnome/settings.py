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
    # NASA wallpapers
    'nasa_apod@elinvention.ovh',
    # Search providers I use often
    'vscode-search-provider@jomik.org',
    'jetbrains-search-provider@swsnr.de',
}


SETTINGS = {
    'org.gnome.desktop.interface': {
        # Disable hot corner for mouse
        'enable-hot-corners': False,
        # Show date and weekday in clock
        'clock-show-date': True,
        'clock-show-weekday': True,
        # Disable Ctrl shortcut for locating the cursor; conflicts with
        # IntelliJs Ctrl shortcut to add multiple cursors
        'locate-pointer': False,
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
}


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
    },
    'org.gnome.settings-daemon.plugins.media-keys': {
        'terminal': ['<Super>t']
    }
}

CUSTOM_BINDINGS = {}

GNOME_TERMINAL_PROFILE = {
    'audible-bell': False,
    'bold-is-bright': False,
    'default-size-columns': 120,
    'default-size-rows': 40,
    'font': 'PragmataPro Mono Liga 11',
    'use-system-font': False,
    'visible-name': 'Shell'
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


def apply_profile_settings(profile_id):
    schema = 'org.gnome.Terminal.Legacy.Profile'
    path = f'/org/gnome/terminal/legacy/profiles:/:{profile_id}/'
    from pprint import pprint; pprint(path)
    profile = Gio.Settings.new_with_path(schema_id=schema, path=path)
    for key, value in GNOME_TERMINAL_PROFILE.items():
        print(f'{schema}:{path} {key} {value}')
        set_pytype(profile, key, value)


def apply_gnome_terminal_profile():
    profiles_list = Gio.Settings(schema='org.gnome.Terminal.ProfilesList')
    profile_id = profiles_list.get_string('default')
    apply_profile_settings(profile_id)


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
    apply_gnome_terminal_profile()
    enable_extensions()


if __name__ == '__main__':
    main()
