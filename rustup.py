#!/usr/bin/env python3

import sys
import shutil
from subprocess import check_call


CRATES = [
    'cargo-update',
    'cargo-outdated',
    'cargo-release',
    'cargo-graph',
    'cargo-license',
    'xkpwgen',
    'tealdeer',
]


TOOLCHAINS = [
    'stable',
    'nightly'
]


def setup_toolchain(rustup, toolchain):
    """
    Setup the given `toolchain`, eg, `stable` or `nightly`, with `rustup`.
    """
    check_call([rustup, 'toolchain', 'install', toolchain])
    for component in ['rustfmt-preview', 'rls-preview']:
        check_call([rustup, 'component',
                    'add',
                    '--toolchain', toolchain,
                    component])
    # On nightly toolchains, also install clippy
    if toolchain.startswith('nightly'):
        check_call([rustup, 'component',
                    'add',
                    '--toolchain', toolchain,
                    'clippy-preview'])


def main():
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
