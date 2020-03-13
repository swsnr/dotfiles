#!/bin/sh
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

# Import environment from fish
eval "$(fish -l -c dump_env_posix)"

# Make Qt5 apps use qt5ct
export QT_QPA_PLATFORMTHEME=qt5ct

# Start SSH agent if not already running
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(/usr/bin/gnome-keyring-daemon --start --components=ssh)"
    export SSH_AUTH_SOCK
fi

# Restore screen layout (GDM runs on wayland and doesn't help us here)
if [ -z "$XRDP_SESSION" ]; then
    # Don't update displays in an XRDP session.
    autorandr --change --default clone-largest
else
    # Make remote output the primary display
    xrandr --output rdp0 --primary
fi

# Load current i3 theme if present
i3_theme="$HOME/.config/i3/themes/current"
if [ -f "$i3_theme" ]; then
    xrdb -merge "$i3_theme"
fi
