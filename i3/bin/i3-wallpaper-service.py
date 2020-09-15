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
import logging
from pathlib import Path
from urllib.parse import urlparse
from subprocess import DEVNULL, run
from systemd.journal import JournalHandler
from gi.repository import Gio, GLib


LOG = logging.getLogger('i3-wallpaper-service')


def x11_number_of_monitors():
    process = run(['xrandr', '--listactivemonitors'], check=True,
                  capture_output=True, encoding='utf-8')
    return len(process.stdout.splitlines()[1:])


def x11_set_wallpapers(files):
    cmd = ['feh', '--no-fehbg', '--bg-fill']
    cmd.extend(files)
    run(cmd, check=True, stdout=DEVNULL, stderr=DEVNULL)


def update_wallpaper(settings):
    wallpaper = settings.get_string('picture-uri')
    path = Path(urlparse(wallpaper).path)
    if not path.is_file():
        raise FileNotFoundError(path)
    no_monitors = x11_number_of_monitors()
    LOG.info(f'Setting wallpaper {path} on all {no_monitors} monitor(s)')
    x11_set_wallpapers([path] * no_monitors)


def update_wallpaper_safe(settings):
    try:
        update_wallpaper(settings)
    except Exception as error:
        LOG.exception(f'Failed to set wallpaper: {error}')


def update_wallpaper_at_start(settings):
    update_wallpaper_safe(settings)
    # Stop the timeout source
    return False


def picture_uri_changed(settings, key):
    if key != 'picture-uri':
        LOG.warning(
            'Unexpected change signal for key {key}; we did not subscribe to this')
        return
    else:
        update_wallpaper_safe(settings)


def main():
    logging.getLogger().addHandler(JournalHandler())
    LOG.setLevel(logging.INFO)

    try:
        settings = Gio.Settings(schema='org.gnome.desktop.background')

        settings.connect('changed::picture-uri', picture_uri_changed)
        GLib.timeout_add(0, lambda: update_wallpaper_at_start(settings))
        GLib.MainLoop().run()
    except Exception as error:
        LOG.exception(f'Failed to start blocket: {error}')
        sys.exit(1)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
