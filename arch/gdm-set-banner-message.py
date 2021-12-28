#!/usr/bin/python3
# Copyright Sebastian Wiesner <sebastian@swsnr.de>
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
Set a GDM banner message.

See <https://help.gnome.org/admin/system-admin-guide/stable/login-banner.html.en>
"""

import argparse
import subprocess
from pathlib import Path

import gi
from gi.repository import GLib


def main():
    parser = argparse.ArgumentParser(description='Set GDM banner message')
    parser.add_argument('message')
    args = parser.parse_args()

    message = GLib.Variant.new_string(args.message)
    target = Path('/etc/dconf/db/gdm.d/01-dotfiles-lunaryorn-banner-message')
    target.parent.mkdir(parents=True, exist_ok=True)

    content = f"""\
[org/gnome/login-screen]
banner-message-enable=true
banner-message-text={message}"""
    print(f'Writing {target}')
    target.write_text(content)

    print('dconf update')
    subprocess.run(['dconf', 'update'])

if __name__ == '__main__':
    main()