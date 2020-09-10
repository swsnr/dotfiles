#!/bin/bash
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

distro="$(lsb_release -is)"

case "$distro" in
Ubuntu)
    declare -a packages
    packages=(
        # Basics
        "i3-wm"
        "i3status"
        # Locking
        xss-lock
        xsecurelock
        # Notifications
        "dunst"
        # Launcher
        "rofi"
        # Screenshots
        "flameshot"
        # Pulseadio systray (TODO: Find alternative?)
        "pasystray"
        # Desktop background
        "feh"
        # Policy Kit helper
        lxpolkit
        # Power management
        "xfce4-power-manager"
        # Additional apps
        "zathura"
        "zathura-pdf-poppler"
        "nomacs"
        # Pulseaudio settings
        "pavucontrol"
        "paprefs"
        # Display layout editing and profiles
        "autorandr"
        "arandr"
    )

    sudo apt install "${packages[@]}"
    ;;
*)
    echo "Unsupported distribution: ${distro}" 1>&2
    exit 1
    ;;

esac
