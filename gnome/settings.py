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
from pathlib import Path
from gi.repository import Gio


SETTINGS = {
    'org.gnome.mutter': {
        'dynamic-workspaces': True,
        # Switch workspaces on all screens
        'workspaces-only-on-primary': False,
    },

    # Desktop settings
    'org.gnome.system.location': {
        # Enable location service
        'enabled': True
    },
    'org.gnome.desktop.calendar': {
        # Show week numbers in calendar
        'show-weekdate': True
    },
    'org.gnome.desktop.input-sources': {
        # compose:ralt: Set compose key to right alt key, according to my moonlander layout
        # numpad:mac: Always use numpad for nummeric keys, never for arrows and stuff
        'xkb-options': ['compose:ralt', 'numpad:mac']
    },
    'org.gnome.desktop.interface': {
        # Themes and fonts
        'icon-theme': None,
        'gtk-theme': None,
        'font-name': None,
        'document-font-name': None,
        'monospace-font-name': None,
        # Disable hot corner
        'enable-hot-corners': False,
        # Show date and weekday in clock
        'clock-show-date': True,
        'clock-show-weekday': True,
        # Disable Ctrl shortcut for locating the cursor; conflicts with
        # IntelliJs Ctrl shortcut to add multiple cursors
        'locate-pointer': False
    },
    'org.gnome.desktop.peripherals.keyboard': {
        'remember-numlock-state': True,
    },

    # Window manager settings
    'org.gnome.desktop.wm.preferences': {
        'titlebar-font': None
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
        'toggle-fullscreen': ['<Super>Return'],
        # Switch to and move workspaces
        'switch-to-workspace-1': ['<Super>1'],
        'switch-to-workspace-2': ['<Super>2'],
        'switch-to-workspace-3': ['<Super>3'],
        'switch-to-workspace-4': ['<Super>4'],
        'switch-to-workspace-5': ['<Super>5'],
        'switch-to-workspace-6': ['<Super>6'],
        'move-to-workspace-1': ['<Shift><Super>1'],
        'move-to-workspace-2': ['<Shift><Super>2'],
        'move-to-workspace-3': ['<Shift><Super>3'],
        'move-to-workspace-4': ['<Shift><Super>4'],
        'move-to-workspace-5': ['<Shift><Super>5'],
        'move-to-workspace-6': ['<Shift><Super>6'],
    },

    # Shell settings
    'org.gnome.shell.keybindings': {
        # Disable default shortcuts for application launchers (Super+<number>)
        # I prefer to have these for workspace switching
        'switch-to-application-1': [],
        'switch-to-application-2': [],
        'switch-to-application-3': [],
        'switch-to-application-4': [],
        'switch-to-application-5': [],
        'switch-to-application-6': [],
        'switch-to-application-7': [],
        'switch-to-application-8': [],
        'switch-to-application-9': [],
    },
    'org.gnome.shell.app-switcher': {
        # Limit app and window switcher to current workspace
        'current-workspace-only': True,
    },

    # Application settings
    'org.gnome.software': {
        # Don't educate me Gnome
        'show-nonfree-ui': False,
        'prompt-for-nonfree': False,
        # I'll handle this myself
        'enable-repos-dialog': False,
    }
}

EXTENSION_SETTINGS = {
    'burn-my-windows@schneegans.github.com': {
        'org.gnome.shell.extensions.burn-my-windows':{
            # Burn my window effects <3
            'apparition-close-effect': True,
            'apparition-open-effect': True,
            'broken-glass-close-effect': True,
            'destroy-dialogs': True,
            'doom-open-effect': True,
            'glide-close-effect': True,
            'glide-open-effect': True,
            'hexagon-additive-blending': True,
            'incinerate-close-effect': True,
            'incinerate-use-pointer': True,
            'tv-open-effect': True,
            'wisps-close-effect': True,
            'wisps-open-effect': True,
        }
    },
    'tiling-assistant@leleat-on-github': {
        # Gaps between windows and to the screen borders
        'single-screen-gap': 4,
        'window-gap': 4,
        # Adapt keybindings if the focused window is in tiled state: 1 means
        # instead of adjusting the tiling switch focused window in the direction
        # of the keybinding
        'dynamic-keybinding-behaviour': 1,
    }
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
    if value is None:
        settings.reset(key)
    elif isinstance(value, str):
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
    default_source = Gio.SettingsSchemaSource.get_default()
    for schema_id, items in SETTINGS.items():
        schema = default_source.lookup(schema_id, False)
        if schema:
            settings = Gio.Settings.new_full(schema=schema, backend=None,
                                             path=None)
            apply_settings(settings, items)
        else:
            print(f'Skipping non-existing schema {schema_id}', file=sys.stderr)

    extension_prefixes = [
        Path('/usr/share/gnome-shell/extensions'),
        Path.home() / 'local' / 'share' / 'gnome-shell' / 'extensions',
    ]
    for uuid, schemas in EXTENSION_SETTINGS.items():
        schema_dirs = (p / uuid / 'schemas' for p in extension_prefixes)
        schema_dir = next((d for d in schema_dirs if d.exists()), None)
        if schema_dir:
            source = Gio.SettingsSchemaSource.new_from_directory(
                directory=str(schema_dir),
                parent=default_source,
                trusted=True
            )
        else:
            # Some extensions get packaged to install their schemas into the
            # standard schema dir; that's somewhat unususal, but not a bad idea,
            # so let's support it.
            source = default_source
        for schema_id, items in schemas.items():
            schema = source.lookup(schema_id, False)
            if schema:
                settings = Gio.Settings.new_full(schema=schema, backend=None,
                                                 path=None)
                apply_settings(settings, items)
            else:
                print(f'Schema {schema_id} does not exist; extension {uuid} not installed?',
                      file=sys.stderr)

    bindings_schema = 'org.gnome.settings-daemon.plugins.media-keys.custom-keybinding'
    if not default_source.lookup(bindings_schema, False):
        print('Schema for custom keybindings not found, skipping', file=sys.stderr)
    else:
        new_bindings = []
        removed_bindings = []
        for id, binding in BINDINGS.items():
            path = f'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/{id}/'
            settings = Gio.Settings.new_with_path(
                schema_id=bindings_schema, path=path)
            if not binding:
                schema = settings.get_property('settings-schema')
                for key in schema.list_keys():
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
