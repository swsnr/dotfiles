#!/bin/sh
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

# Import environment from fish
eval "$(fish -l -c dump_env_posix)"

case "${XDG_CURRENT_DESKTOP}" in
    *i3*)
      # Enable i3 theme
    i3_theme="$HOME/.config/i3/themes/current"
    if [ -f "$i3_theme" ]; then
        xrdb -merge "$i3_theme"
    fi

    # Start an SSH agent if we don't already have one from GDM
    if [ -z "$SSH_AUTH_SOCK" ]; then
      eval "$(ssh-agent)"
      export SSH_AUTH_SOCK
    fi

    # Keyboard layout
    setxkbmap -layout us -variant mac

    # Restore screen layout
    autorandr --change --default horizontal >/dev/null 2>&1
    ;;
esac
