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

import sys
from gi.repository import Gio

SETTINGS = {
    'org.gnome.desktop.interface': {
        # Themes and fonts
        'icon-theme': 'Arc',
        'gtk-theme': 'Arc-Darker',
        'font-name': 'Ubuntu 10',
        'document-font-name': 'Ubuntu 10',
        # Disable hot corner
        'enable-hot-corners': False,
        # Show date and weekday in clock
        'clock-show-date': True,
        'clock-show-weekday': True,
        # Disable Ctrl shortcut for locating the cursor; conflicts with
        # IntelliJs Ctrl shortcut to add multiple cursors
        'locate-pointer': False
    },
    'org.gnome.shell.app-switcher': {
        # Limit app and window switcher to current workspace"""  """
        'current-workspace-only': True
    },
    'org.gnome.system.location': {
        # Enable location service
        'enabled': True
    },
    'org.gnome.desktop.peripherals.keyboard': {
        'remember-numlock-state': True,
        'numlock-state': True
    },
    'org.gnome.desktop.input-sources': {
        # compose:ralt: Set compose key to right alt key, according to my moonlander layout
        # numpad:mac: Always use numpad for nummeric keys, never for arrows and stuff
        'xkb-options': ['compose:ralt', 'numpad:mac']
    },
    'org.gnome.desktop.calendar': {
        # Show week numbers in calendar
        'show-weekdate': True
    },
    'org.gnome.mutter': {
        'dynamic-workspaces': True
    },
    'org.gnome.desktop.wm.preferences': {
        'titlebar-font': 'Ubuntu Bold 10'
    },
    'org.gnome.desktop.wm.keybindings': {
        'close': ['<Super>q', '<Alt>F4'],
        # Switch windows not applications
        'switch-applications': [],
        'switch-applications-backward': [],
        'switch-group': [],
        'switch-group-backward': [],
        'switch-windows': ['<Super>Tab', '<Alt>Tab'],
        'switch-windows-backward': ['<Shift><Super>Tab', '<Shift><Alt>Tab'],
        # Keep on top above all other windows
        'always-on-top': ['<Shift><Super>t'],
        'toggle-on-all-workspaces': ['<Super>period'],
        # Disable input method switching wtih Super+Space
        'switch-input-source': ['XF86Keyboard'],
        'switch-input-source-backward': ['<Shift>XF86Keyboard'],
        # Toogle fullscreen
        'toggle-fullscreen': ['<Super>Return']
    }
}

TERMINAL_PROFILE = {
    'audible-bell': False,
    'bold-is-bright': False,
    'default-size-columns': 120,
    'default-size-rows': 40,
    'font': 'PragmataPro Mono Liga 11',
    'use-system-font': False,
    'visible-name': 'Shell',
    # Enable dracula theme for terminal
    'use-theme-colors': False,
    'bold-color-same-as-fg': False,
    'foreground-color': '#F8F8F2',
    'background-color': '#282A36',
    'bold-color': '#6E46A4',
    'palette': [
        '#262626',
        '#E356A7',
        '#42E66C',
        '#E4F34A',
        '#9B6BDF',
        '#E64747',
        '#75D7EC',
        '#EFA554',
        '#7A7A7A',
        '#FF79C6',
        '#50FA7B',
        '#F1FA8C',
        '#BD93F9',
        '#FF5555',
        '#8BE9FD',
        '#FFB86C',
    ]
}

BINDINGS = {
    'terminal': False,
    'toggle-theme': {
        'name': 'Toggle UI theme',
        'command': 'ui-theme toggle',
        'binding': '<Super>apostrophe'
    },
    'onepassword-quick': {
        'name': '1Password quick access',
        'command': '1password --quick-access',
        'binding': '<Super>o'
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


def apply_settings(settings, items):
    settings_schema = settings.get_property('settings-schema')
    schema = settings.get_property('schema')
    for key, value in items.items():
        if settings_schema.has_key(key):
            print(f'{schema}.{key} = {value}')
            set_pytype(settings, key, value)
        else:
            print(f'{schema}.{key} does not exist!', file=sys.stderr)


def main():
    source = Gio.SettingsSchemaSource.get_default()
    for schema, items in SETTINGS.items():
        if source.lookup(schema, False):
            settings = Gio.Settings(schema=schema)
            apply_settings(settings, items)
        else:
            print(f'Skipping non-existing schema {schema}', file=sys.stderr)

    if not source.lookup('org.gnome.Terminal.ProfilesList', False):
        print('Terminal profile list not available, skipping', file=sys.stderr)
    else:
        profiles_list = Gio.Settings(
            schema='org.gnome.Terminal.ProfilesList')
        profile_id = profiles_list.get_string('default')
        schema = 'org.gnome.Terminal.Legacy.Profile'
        path = f'/org/gnome/terminal/legacy/profiles:/:{profile_id}/'
        settings = Gio.Settings.new_with_path(schema_id=schema, path=path)
        apply_settings(settings, TERMINAL_PROFILE)

    bindings_schema = 'org.gnome.settings-daemon.plugins.media-keys.custom-keybinding'
    if not source.lookup(bindings_schema, False):
        print('Schema for custom keybindings not found, skipping', file=sys.stderr)
    else:
        new_bindings = []
        removed_bindings = []
        for id, binding in BINDINGS.items():
            path = f'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/{id}/'
            settings = Gio.Settings.new_with_path(
                schema_id=bindings_schema, path=path)
            if not binding:
                settings_schema = settings.get_property('settings-schema')
                for key in settings_schema.list_keys():
                    settings.reset(key)
                print(f'binding {id} removed')
                removed_bindings.append(path)
            else:
                settings.set_string('name', binding['name'])
                settings.set_string('command', binding['command'])
                settings.set_string('binding', binding['binding'])
                print('{id} {binding}: {name} ({command})'.format(
                    id=id, **binding))
                new_bindings.append(path)

        media_keys = Gio.Settings(
            schema='org.gnome.settings-daemon.plugins.media-keys')
        custom_bindings = media_keys.get_strv('custom-keybindings')
        for path in new_bindings:
            if path not in custom_bindings:
                custom_bindings.append(path)
        for path in removed_bindings:
            if path in custom_bindings:
                custom_bindings.remove(path)
        media_keys.set_strv('custom-keybindings', custom_bindings)


if __name__ == '__main__':
    main()
