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
import shutil
from argparse import ArgumentParser
from subprocess import check_call


CRATES = [
    'cargo-update',
    'cargo-outdated',
    'cargo-release',
    'cargo-graph',
    'cargo-license',
    'git-gone',
    'xkpwgen',
]


TOOLCHAINS = ['stable']


def setup_toolchain(rustup, toolchain):
    """
    Setup the given `toolchain`, eg, `stable` or `nightly`, with `rustup`.
    """
    check_call([rustup, 'toolchain', 'install', toolchain])
    for component in ['rustfmt-preview', 'rls-preview', 'clippy-preview']:
        check_call([rustup, 'component',
                    'add',
                    '--toolchain', toolchain,
                    component])


def main():
    parser = ArgumentParser(description="""\
Setup rust.  Install toolchains and toolchain components, and crates I use.
""")
    parser.parse_args()

    rustup = shutil.which('rustup')
    if not rustup:
        sys.exit('rustup missing; install from https://rustup.rs!')

    check_call([rustup, 'self', 'update'])
    check_call([rustup, 'update'])

    for toolchain in TOOLCHAINS:
        setup_toolchain(rustup, toolchain)

    # Setup stable as default toolchain
    check_call([rustup, 'default', 'stable'])

    # Install all crates
    cargo = shutil.which('cargo')
    if not cargo:
        sys.exit('cargo missing; something went wrong with toolchains!')

    for crate in CRATES:
        check_call([cargo, 'install', '--force', crate])


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        pass
