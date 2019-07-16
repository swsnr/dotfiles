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

# POSIX shell profile for global environment, because not all environment source
# fish's settings.

case "${XDG_CURRENT_DESKTOP}" in
    XFCE | *GNOME | i3)
        # On XFCE, Gnome and i3 make Qt appearance configurable
        export QT_QPA_PLATFORMTHEME=qt5ct;
        # Enable Gnome Keyring SSH
        eval "$(/usr/bin/gnome-keyring-daemon --start --components=ssh)"
        export SSH_AUTH_SOCK
        ;;
esac

# Import paths from fish
export "$(fish -l -c env | grep -e '^PATH=')"
export "$(fish -l -c env | grep -e '^MANPATH=')"
export "$(fish -l -c env | grep -e '^INFOPATH=')"

if [ -n "$DISPLAY" ]; then
  # Restore numlock on X11
  numlockx on
fi

