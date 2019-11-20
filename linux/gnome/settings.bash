#!/bin/bash
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

set -e

if [[ "$OSTYPE" != "linux-gnu" ]]; then
    echo "Skipping, not on Linux"
    exit 0
fi

function gs {
    echo "gsettings set $*"
    gsettings set "${@}"
}

# Gtk theme and fonts
gs org.gnome.desktop.interface gtk-theme Yaru-dark
gs org.gnome.desktop.interface icon-theme Yaru
gs org.gnome.desktop.interface font-name 'Ubuntu 12'
gs org.gnome.desktop.interface document-font-name 'Ubuntu 12'
gs org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 11'

# Enable location services
gs org.gnome.system.location enabled true

# Show date and weekday in clock
gs org.gnome.desktop.interface clock-show-date true
gs org.gnome.desktop.interface clock-show-weekday true

# Press left CTRL to trigger a mouse pointer animation (to find it on a big screen)
gs org.gnome.desktop.interface locate-pointer true
# Don't remember the numlock state…
gs org.gnome.desktop.peripherals.keyboard remember-numlock-state false
# …and instead turn on numlock on boot.j
gs org.gnome.desktop.peripherals.keyboard numlock-state true

# Include active terminal title in Tilix window title (we deliberage don't expand here!)
# shellcheck disable=SC2016
gs com.gexperts.Tilix.Settings app-title '${appName}: ${activeTerminalTitle}'
# Quit tilix when last session closes
gs com.gexperts.Tilix.Settings close-with-last-session true
# Don't warn about VTE config issues; my fish config works :)
gs com.gexperts.Tilix.Settings warn-vte-config-issue false
