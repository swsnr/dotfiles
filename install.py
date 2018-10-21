#!/usr/bin/env python3
# Copyright 2018 Sebastian Wiesner <sebastian@swsnr.de>
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
import shutil
import socket
from subprocess import check_call


BASEDIR = os.path.abspath(os.path.dirname(__file__))
DOTBOT_DIR = os.path.join(BASEDIR, 'dotbot')
DOTBOT_BIN = os.path.join(DOTBOT_DIR, 'bin', 'dotbot')


def dotbot(directory, config, args=None):
    cmd = [sys.executable, DOTBOT_BIN, '-d', directory, '-c', config]
    if args:
        cmd.extend(args)
    check_call(cmd, cwd=BASEDIR)


def main():
    if sys.version_info < (3, 2):
        sys.exit('Need Python 3.2 or newer')

    # Find git to update submodules
    git = shutil.which('git')
    if not git:
        sys.exit('MISSING GIT')

    check_call([git, '-C', DOTBOT_DIR, 'submodule',
                'sync', '--quiet', '--recursive'])
    check_call([git, '-C', BASEDIR, 'submodule',
                'update', '--init', '--recursive'])

    dotbot(BASEDIR, 'install.conf.yaml')

    if sys.platform == 'darwin':
        dotbot(BASEDIR, os.path.join('macos', 'install.conf.yaml'))
    elif sys.platform == 'linux':
        dotbot(BASEDIR, os.path.join('linux', 'install.conf.yaml'))
    elif sys.platform == 'win32':
        dotbot(BASEDIR, os.path.join('windows', 'install.conf.yaml'))

    hostname = socket.gethostname()
    if hostname.endswith('.uberspace.de'):
        dotbot(BASEDIR, os.path.join('uberspace', 'install.conf.yaml'))


if __name__ == '__main__':
    main()
