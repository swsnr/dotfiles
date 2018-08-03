#!/usr/bin/env python3

import sys
import os
import shutil
from subprocess import check_call


BASEDIR = os.path.abspath(os.path.dirname(__file__))
DOTBOT_DIR = os.path.join(BASEDIR, 'dotbot')
DOTBOT_BIN = os.path.join(DOTBOT_DIR, 'bin', 'dotbot')


GIT = shutil.which('git')
PYTHON = shutil.which('python3') or shutil.which('python')


def dotbot(directory, config, args=None):
    cmd = [PYTHON, DOTBOT_BIN, '-d', directory, '-c', config]
    if args:
        cmd.extend(args)
    check_call(cmd, cwd=BASEDIR)


def main():
    if not GIT:
        sys.exit('MISSING GIT')
    if not PYTHON:
        sys.exit('MISSING PYTHON')

    check_call([GIT, '-C', DOTBOT_DIR, 'submodule', 'sync', '--quiet', '--recursive'])
    check_call([GIT, '-C', BASEDIR, 'submodule', 'update', '--init', '--recursive'])

    dotbot(BASEDIR, 'install.conf.yaml')

    if sys.platform == 'darwin':
        dotbot(BASEDIR, os.path.join('macos', 'install.conf.yaml'))
    elif sys.platform == "win32":
        dotbot(BASEDIR, os.path.join('windows', 'install.conf.yaml'))


if __name__ == '__main__':
    main()
