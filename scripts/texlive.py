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
from subprocess import check_call


def tlmgr(args):
    return check_call(['sudo', 'tlmgr'] + args)


def tlmgr_set_option(option, value):
    return tlmgr(['option', option, str(value)])


PACKAGES = [
    'latexmk',
    'texdoc'
]


def main():
    parser = ArgumentParser(
        description="""\
Setup texlive: Configure tlmgr and install packages.
""",
        epilog='MAY PROMPT FOR SUDO PASSWORD!')
    parser.parse_args()

    # Install documentation along with packages, for texdoc
    tlmgr_set_option('docfiles', 1)
    # Update texlive manager and packages
    tlmgr(['update', '--self', '--all'])
    # Install texlive packages
    if PACKAGES:
        tlmgr(['install'] + PACKAGES)


if __name__ == '__main__':
    main()
