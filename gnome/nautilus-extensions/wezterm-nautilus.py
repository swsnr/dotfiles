# Copyright (C) 2022 Sebastian Wiesner <sebastian@swsnr.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


from gi import require_version
require_version('Nautilus', '3.0')
from gi.repository import Nautilus, GObject, Gio, GLib


class OpenInWezTermAction(GObject.GObject, Nautilus.MenuProvider):
    def __init__(self):
        super().__init__()
        session = Gio.bus_get_sync(Gio.BusType.SESSION, None)
        self._systemd = Gio.DBusProxy.new_sync(session, Gio.DBusProxyFlags.NONE,
            None,
            "org.freedesktop.systemd1",
            "/org/freedesktop/systemd1",
            "org.freedesktop.systemd1.Manager", None)

    def _open_terminal(self, file):
        cmd = ['wezterm', 'start', '--cwd', file.get_location().get_path()]
        child = Gio.Subprocess.new(cmd, Gio.SubprocessFlags.NONE)
        pid = int(child.get_identifier())
        props = [("PIDs", GLib.Variant('au', [pid])),
            ('CollectMode', GLib.Variant('s', 'inactive-or-failed'))]
        name = f'app-nautilus-org.wezfurlong.wezterm-{pid}.scope'
        args = GLib.Variant('(ssa(sv)a(sa(sv)))', (name, 'fail', props, []))
        self._systemd.call_sync( 'StartTransientUnit', args,
                Gio.DBusCallFlags.NO_AUTO_START, 500, None)

    def _menu_activate_cb(self, _menu, file):
        self._open_terminal(file)

    def _make_item(self, file, name):
        if file.is_directory and file.get_location().get_path():
            item = Nautilus.MenuItem(name=name, label='Open in WezTerm',
                    icon='org.wezfurlong.wezterm')
            item.connect('activate', self._menu_activate_cb, file)
            return item
        else:
            return None

    def get_file_items(self, window, files):
        items = []
        for file in files:
            item = self._make_item(file, name='WezTermNautilus::open_in_wezterm')
            if item:
                items.append(item)
        return items

    def get_background_items(self, window, file):
        item = self._make_item(file,
                name='WezTermNautilus::open_folder_in_wezterm')
        if item:
            return [item]
        else:
            return None
