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

from argparse import ArgumentParser
import random
from pathlib import Path
from subprocess import check_output, check_call


PICTURE_DIR = Path(check_output(['xdg-user-dir',
                                 'PICTURES']).rstrip().decode('utf-8'))

DIRECTORIES = [
    PICTURE_DIR / 'APOD',
    PICTURE_DIR / 'Space',
]


EXTENSIONS = {'.jpg', '.jpeg', '.png'}


def wallpaper_files():
    return [item for directory in DIRECTORIES for item in
            directory.iterdir()
            if item.is_file() and item.suffix.lower() in EXTENSIONS]


def number_of_monitors():
    output = check_output(['xrandr', '--listactivemonitors'])
    return len(output.splitlines()[1:])


def set_wallpapers(files):
    cmd = ['feh', '--no-fehbg', '--bg-fill']
    cmd.extend(files)
    check_call(cmd)


def main():
    parser = ArgumentParser(
        description='Set a random wallpaper on each monitor')
    parser.parse_args()

    wallpapers = random.sample(wallpaper_files(), number_of_monitors())
    set_wallpapers(wallpapers)


if __name__ == '__main__':
    main()
