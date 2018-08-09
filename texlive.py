#!/usr/bin/env python3


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
    print('Install and update texlive packages; may prompt for sudo password!')
    # Install documentation along with packages, for texdoc
    tlmgr_set_option('docfiles', 1)
    # Update texlive manager and packages
    tlmgr(['update', '--self', '--all'])
    # Install texlive packages
    if PACKAGES:
        tlmgr(['install'] + PACKAGES)


if __name__ == '__main__':
    main()
