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

"""
Configure VSCode and install some basic extensions.
"""

import sys
import shutil
from argparse import ArgumentParser
from subprocess import check_output, check_call


# Extensions to remove in favour of other extensions
OLD_EXTENSIONS = [
    # Superseded by 'crates'
    'belfz.search-crates-io',
    # Gone.
    'TeddyDD.fish',
]


EXTENSIONS = [
    'PKief.material-icon-theme',
    # Support .editorconfig files
    'EditorConfig.EditorConfig',
    # Rewrap paragraphs like in Emcas
    'stkb.rewrap',
    # LaTeX editing
    'James-Yu.latex-workshop',
    # TOML for crate manifests and for hugo frontmatter
    'bungcip.better-toml',
    # Git extensions, git ignore files and Github integration
    'eamodio.gitlens',
    'codezombiech.gitignore',
    'github.vscode-pull-request-github',
    # Rust language support and crate search in crate manifests
    'rust-lang.rust',
    'serayuzgur.crates',
    # Misc languages
    'ms-vscode.vscode-typescript-tslint-plugin',
    'scalameta.metals',
    'lunaryorn.fish-ide',
    'ms-python.python',
    'ms-vscode.powershell',
]


def installed_extensions(code):
    output = check_output(
        [code, '--list-extensions']).decode(sys.getdefaultencoding())

    return set(line.lower() for line in output.splitlines())


def main():
    parser = ArgumentParser(description='Install vscode extensions')
    parser.parse_args()

    code = shutil.which('code')
    if not code:
        sys.exit('Did not find `code` in `$PATH`.  Is VSCode installed?')

    installed = installed_extensions(code)

    for extension in OLD_EXTENSIONS:
        if extension.lower() in installed:
            check_call([code, '--uninstall-extension', extension])
    for extension in EXTENSIONS:
        if extension.lower() not in installed:
            check_call([code, '--install-extension', extension])


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        pass
