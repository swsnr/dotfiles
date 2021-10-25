# Copyright 2020 Sebastian Wiesner <sebastian@swsnr.de>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

from dotbot import Plugin


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


class GSettings(Plugin):
    _directives = {'gsettings', 'gnome_terminal_profile'}

    def can_handle(self, directive):
        return directive in self._directives

    def _apply_settings(self, settings, items):
        all_keys_applied = True

        settings_schema = settings.get_property('settings-schema')
        schema = settings.get_property('schema')
        for key, value in items.items():
            if settings_schema.has_key(key):
                self._log.lowinfo(f'{schema} {key} {value}')
                set_pytype(settings, key, value)
            else:
                self._log.error(f'{schema} {key} does not exist!')
                all_keys_applied = False
        return all_keys_applied

    def handle(self, directive, data):
        if directive not in self._directives:
            raise ValueError(directive)

        try:
            from gi.repository import Gio
        except ImportError:
            self.log._error('Gio module not available')
            return False

        source = Gio.SettingsSchemaSource.get_default()

        all_keys_applied = True

        if directive == 'gnome_terminal_profile':
            if source.lookup('org.gnome.Terminal.ProfilesList', False):
                profiles_list = Gio.Settings(
                    schema='org.gnome.Terminal.ProfilesList')
                profile_id = profiles_list.get_string('default')
                schema = 'org.gnome.Terminal.Legacy.Profile'
                path = f'/org/gnome/terminal/legacy/profiles:/:{profile_id}/'
                if not self._apply_settings(Gio.Settings.new_with_path(
                        schema_id=schema, path=path), data):
                    all_keys_applied = False
            else:
                self._log.info('Gnome Terminal not installed; skipping')
        else:
            for schema, items in data.items():
                if source.lookup(schema, False):
                    if not self._apply_settings(Gio.Settings(schema=schema), items):
                        all_keys_applied = False
                else:
                    self._log.info(
                        'Skipping schema {}, does not exist'.format(schema))

        if all_keys_applied:
            self._log.info('All settings applied successfully')
        else:
            self._log.error('Some settings not applied!')

        return all_keys_applied


class GnomeCustomBindings(Plugin):

    _directive = 'gnome_bindings'
    _schema_id = 'org.gnome.settings-daemon.plugins.media-keys.custom-keybinding'

    def _path(self, id):
        return f'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/{id}/'

    def can_handle(self, directive):
        return directive == self._directive

    def handle(self, directive, data):
        if directive != self._directive:
            raise ValueError(directive)

        try:
            from gi.repository import Gio
        except ImportError:
            self.log._error('Gio module not available')
            return False

        source = Gio.SettingsSchemaSource.get_default()
        if not source.lookup(self._schema_id, False):
            self._log.info('Schema for custom keybindings not found, skipping')
            return True

        new_bindings = []
        removed_bindings = []
        for id, attrs in data.items():
            binding = attrs['binding']
            path = self._path(id)
            settings = Gio.Settings.new_with_path(
                self._schema_id, path=path)
            if not binding:
                settings_schema = settings.get_property('settings-schema')
                for key in settings_schema.list_keys():
                    settings.reset(key)
                self._log.lowinfo(f'Unbind {id}')
                removed_bindings.append(path)
            else:
                name = attrs['name']
                command = attrs['command']
                settings.set_string('name', name)
                settings.set_string('command', command)
                settings.set_string('binding', binding)
                self._log.lowinfo(f'{id} {binding}: {name} ({command})')
                new_bindings.append(path)

        media_keys = Gio.Settings(
            schema='org.gnome.settings-daemon.plugins.media-keys')
        custom_bindings = media_keys.get_strv('custom-keybindings')
        for path in new_bindings:
            if path not in custom_bindings:
                custom_bindings.append(path)
        for path in removed_bindings:
            custom_bindings.remove(path)
        media_keys.set_strv('custom-keybindings', custom_bindings)

        return True
