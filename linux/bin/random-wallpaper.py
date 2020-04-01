#!/usr/bin/env python3
# Copyright 2018-2019 Sebastian Wiesner <sebastian@swsnr.de>
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
import random
import os
import json
from argparse import ArgumentParser
from pathlib import Path
from subprocess import check_output, check_call


PICTURE_DIR = Path(check_output(['xdg-user-dir',
                                 'PICTURES']).rstrip().decode('utf-8'))

DIRECTORIES = [
    PICTURE_DIR / 'APOD',
]

EXTENSIONS = {'.jpg', '.jpeg', '.png'}

RUNTIME_DIR = Path(os.environ['XDG_RUNTIME_DIR']
                   ) if 'XDG_RUNTIME_DIR' in os.environ else None


def wallpaper_files():
    return [item for directory in DIRECTORIES for item in
            directory.iterdir()
            if item.is_file() and item.suffix.lower() in EXTENSIONS]


def save_state(wallpaper_files):
    if RUNTIME_DIR:
        data = {'files': list(map(str, wallpaper_files))}
        with open(RUNTIME_DIR / 'random-wallpaper.json', 'w') as sink:
            json.dump(data, sink)


def main():
    parser = ArgumentParser(
        description='Set a random wallpaper for current desktop')
    parser.parse_args()

    if 'GNOME' in os.environ.get('XDG_CURRENT_DESKTOP', ''):
        wallpaper = random.choice(wallpaper_files()).as_uri()
        check_call(['gsettings', 'set', 'org.gnome.desktop.background',
                    'picture-uri', wallpaper])
    else:
        sys.exit('Unsupported desktop environment')


if __name__ == '__main__':
    main()
