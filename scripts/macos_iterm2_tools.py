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

import sys
import os
import hashlib
from urllib import request
from argparse import ArgumentParser

URL = 'https://raw.githubusercontent.com/gnachman/iterm2-website/master/source/utilities/{tool_name}'

TOOLS = {
    'imgcat': 'b5923d2bd5c008272d09fae2f0c1d5ccd9b7084bb8a4912315923fbc3d603cc3',
    'imgls': 'e6c81566996720f20f1ba7dea6cbdb8266db3754a417f6ae845878a8957e92d9'
}


def download_and_verify(url, sha256checksum):
    with request.urlopen(url) as response:
        contents = response.read()
        sha256 = hashlib.sha256()
        sha256.update(contents)
        if sha256.hexdigest() != sha256checksum:
            raise ValueError('URL {} did not match checksum'.format(url))
        return contents


def main():
    parser = ArgumentParser(description="""\
Setup macOS application settings.
""")
    parser.parse_args()

    if sys.platform != 'darwin':
        print('Not on MacOS; skipping')
        return

    for name, checksum in TOOLS.items():
        targetdir = os.path.join('~', '.local', 'bin')
        target = os.path.join(targetdir, name)
        print('Install {} to {}'.format(name, target))

        url = URL.format(tool_name=name)
        contents = download_and_verify(url, checksum)
        os.makedirs(os.path.expanduser(targetdir), exist_ok=True)
        with open(os.path.expanduser(target), 'wb') as sink:
            sink.write(contents)

        os.chmod(os.path.expanduser(target), 0o755)


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        pass
