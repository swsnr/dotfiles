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
import os
from argparse import ArgumentParser
from subprocess import check_call


DEFAULTS = {
    'NSGlobalDomain': {
        # German locale and metric units
        'AppleLocale': 'de_de',
        'AppleMeasurementUnits': 'Centimeters',
        'AppleMetricUnits': True,
    },
    'com.apple.dock': {
        # Do not sort spaces by recent usage to be more predictable.
        'mru-spaces': False,
        # Automatically hide the dock; I don’t use it much
        'autohide': True
    },
    'com.apple.finder': {
        # Don't warn when changing file extensions in Finder
        'FXEnableExtensionChangeWarning': False,
        # Don't warn when emptying the trash can
        'WarnOnEmptyTrash': False
    },
    'com.apple.LaunchServices': {
        # Disable quarantine for downloaded apps
        'LSQuarantine': False
    },
    'com.apple.screencapture': {
        # Save screenshots on the desktop as PNG w/o shadow
        'location': os.path.expanduser('~/Desktop'),
        'type': 'png',
        'disable-shadow': True,
    },
    'com.apple.screensaver': {
        # Immediately ask for password when disabling screen saver
        'askForPassword': True,
        'askForPasswordDelay': 0.0,
    },
    'com.apple.ImageCapture': {
        # Do not ask to import photos when plugging devices
        'disableHotPlug': True
    },
    'com.apple.TimeMachine': {
        # Do not offer disks for TimeMachine backups
        'DoNotOfferNewDisksForBackup': True
    },
    'com.apple.Safari': {
        # Create new tabs in Safari automatically
        'TabCreationPolicy': 1,
        # Make Cmd+Click open new tabs in Safari
        'CommandClickMakesTab': True,
        # Enable Developer menu
        'IncludeDevelopMenu': True
    },
    'com.apple.ActivityMonitor': {
        # Open activity monitor main window
        'OpenMainWindow': True,
        # Show CPU usage in icon when activity monitor is running
        'IconType': 5,
        # Show all processes in activity monitor by default
        'ShowCategory': 0,
        # Sort activity monitor columns by CPU usage by default…
        'SortColumn': 'CPUUsage',
        # …in descending order
        'SortDirection': 0
    }
}


def set_default(domain, key, value):
    cmd = ['defaults', 'write', domain, key]

    if isinstance(value, str):
        cmd.extend(['-string', value])
    elif isinstance(value, bool):
        cmd.extend(['-boolean', str(value).lower()])
    elif isinstance(value, int):
        cmd.extend(['-integer', str(value)])
    elif isinstance(value, float):
        cmd.extend(['-float', str(float)])
    else:
        raise TypeError('Unsupported type: {}'.format(type(value)))

    print(' '.join(cmd))
    check_call(cmd)


def main():
    parser = ArgumentParser(description="""\
Setup macOS application settings.
""")
    parser.parse_args()

    if sys.platform != 'darwin':
        print('Not on MacOS; skipping')
        return

    for domain, settings in DEFAULTS.items():
        for key, value in settings.items():
            set_default(domain, key, value)


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        pass
