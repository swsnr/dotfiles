#!/usr/bin/env python3

"""
Configure VSCode and install some basic extensions.
"""

import shutil
from subprocess import check_call


# Extensions to remove in favour of other extensions
OLD_EXTENSIONS = [
    # Superseded by 'crates'
    'belfz.search-crates-io',
]


EXTENSIONS = [
    # Nice dark theme
    'dracula-theme.theme-dracula',
    # Support .editorconfig files
    'EditorConfig.EditorConfig',
    # Rewrap paragraphs like in Emcas
    'stkb.rewrap',
    # Linter for natural language
    'lunaryorn.vale',
    # LaTeX editing
    'James-Yu.latex-workshop',
    # TOML for crate manifests and for hugo frontmatter
    'bungcip.better-toml',
    # Git extensions, git ignore files and Github integration
    'eamodio.gitlens',
    'codezombiech.gitignore',
    'KnisterPeter.vscode-github',
    # Rust language support and crate search in crate manifests
    'rust-lang.rust',
    'serayuzgur.crates',
    # Misc languages
    'TeddyDD.fish',
    'eg2.tslint',
    'itryapitsin.Sbt',
    'itryapitsin.Scala',
    'lunaryorn.fish-ide',
    'ms-python.python',
    'ms-vscode.cpptools',
]


def main():
    code = shutil.which('code')
    if not code:
        sys.exit('Did not find `code` in `$PATH`.  Is VSCode installed?')
    for extension in OLD_EXTENSIONS:
        check_call([code, '--uninstall-extension', extension])
    for extension in EXTENSIONS:
        check_call([code, '--install-extension', extension])


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        pass
