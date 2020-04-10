#!/bin/bash
# Copyright 2020 Sebastian Wiesner <sebastian@swsnr.de>
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

# Toggle between light and dark themes

set -e

case "$1" in
toggle)
    if gsettings get org.gnome.desktop.interface icon-theme | grep -qi 'light'; then
        theme=dark
    else
        theme=light
    fi
    ;;
dark | light)
    theme="$1"
    ;;
*)
    echo "Unsupported theme: $1" 1>&2
    exit 1
    ;;
esac

echo "$theme"

CODE_SETTINGS="$HOME/.config/Code - OSS/User/settings.json"

function vscode_theme() {
    target="$(mktemp -p "$HOME/.config/Code - OSS/User" .settings.json.XXXXXXXXXX)"
    jq --arg vscode_theme "$1" '.["workbench.colorTheme"] = $vscode_theme' <"$CODE_SETTINGS" >"$target"
    mv "$target" "$CODE_SETTINGS"
}

function tilix_theme() {
    local profile
    local theme_file
    profile="$(gsettings get com.gexperts.Tilix.ProfilesList default | sed -e "s/^'//" -e "s/'\$//")"

    # Don't mess with bold colors
    gsettings set "com.gexperts.Tilix.Profile:/com/gexperts/Tilix/profiles/$profile/" bold-is-bright false

    local theme_file="/usr/share/tilix/schemes/$1.json"

    gsettings set "com.gexperts.Tilix.Profile:/com/gexperts/Tilix/profiles/$profile/" use-theme-colors "$(jq '.["use-theme-colors"]' <"$theme_file")"
    gsettings set "com.gexperts.Tilix.Profile:/com/gexperts/Tilix/profiles/$profile/" background-color "$(jq -r '.["background-color"]' <"$theme_file")"
    gsettings set "com.gexperts.Tilix.Profile:/com/gexperts/Tilix/profiles/$profile/" foreground-color "$(jq -r '.["foreground-color"]' <"$theme_file")"
    gsettings set "com.gexperts.Tilix.Profile:/com/gexperts/Tilix/profiles/$profile/" palette "$(jq -c '.["palette"]' <"$theme_file")"
}

# Gtk theme
# Light
case "$theme" in
light)
    gsettings set org.gnome.desktop.interface gtk-theme 'Arc'
    gsettings set org.gnome.desktop.interface icon-theme 'Numix-Circle-Light'
    gsettings set org.gnome.desktop.interface cursor-theme 'Numix-Cursor-Light'

    vscode_theme 'Solarized Light'
    tilix_theme 'solarized-light'
    ;;
dark)
    gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Numix-Circle'
    gsettings set org.gnome.desktop.interface cursor-theme 'Numix-Cursor'

    vscode_theme 'Solarized Dark'
    tilix_theme 'solarized-dark'
    ;;
*)
    echo "Unsupported theme: $theme" 1>&2
    exit 1
    ;;
esac
