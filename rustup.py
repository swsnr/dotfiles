#!/usr/bin/env python3

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


def main():
    check_call(['rustup', 'self', 'update'])
    check_call(['rustup', 'update'])

    check_call(['rustup', 'default', 'stable'])

    for crate in CRATES:
        check_call(['cargo', 'install', '--force', crate])

    # Clippy needs nightly currently
    check_call(['cargo', '+nightly', 'install', '--force', 'clippy'])


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        pass
