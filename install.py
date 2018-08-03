#!/usr/bin/env python3

import sys
import os
import shutil
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

    check_call([git, '-C', DOTBOT_DIR, 'submodule', 'sync', '--quiet', '--recursive'])
    check_call([git, '-C', BASEDIR, 'submodule', 'update', '--init', '--recursive'])

    dotbot(BASEDIR, 'install.conf.yaml')

    if sys.platform == 'darwin':
        dotbot(BASEDIR, os.path.join('macos', 'install.conf.yaml'))
    elif sys.platform == "win32":
        dotbot(BASEDIR, os.path.join('windows', 'install.conf.yaml'))


if __name__ == '__main__':
    main()
