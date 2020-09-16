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

if [[ "${XDG_CURRENT_DESKTOP}" == i3 && "$(lsb_release -is)" == "Ubuntu" ]]; then
    # Cheat a little to treat a Ubuntu i3 desktop as Ubuntu system
    export XDG_CURRENT_DESKTOP=i3:ubuntu
fi

if [[ "${XDG_CURRENT_DESKTOP}" == i3* ]]; then
    # Point dconf to a custom profile pointing to a custom database;
    # this separates config changes made for i3 from changes made in Gnome sessions
    export DCONF_PROFILE="$HOME/.config/i3/dconf-profile"

    # Enable i3 theme
    i3_theme="$HOME/.config/i3/themes/current"
    if [ -f "$i3_theme" ]; then
        xrdb -merge "$i3_theme"
    fi

    # Restore screen layout
    autorandr --change --default horizontal &>/dev/null
fi

# Make Qt5 apps use qt5ct
#export QT_QPA_PLATFORMTHEME=qt5ct
