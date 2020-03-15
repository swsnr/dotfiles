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

function i3_theme() {
    # Activate the current theme
    ln -sf "$1" ~/.config/i3/themes/current
    # TODO: If running i3, apply the theme
    # xrdb -merge ~/.config/i3/themes/current
    # i3-msg reload
}

function sway_theme() {
    ln -sf "../themes/$1" ~/.config/sway/conf.d/00-theme
    if [[ -n "$SWAYSOCK" ]]; then
        swaymsg reload
    fi
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
    i3_theme 'arc'
    sway_theme 'arc'
    ;;
dark)
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Numix-Circle'
    gsettings set org.gnome.desktop.interface cursor-theme 'Numix-Cursor'

    vscode_theme 'Default Dark+'
    tilix_theme monokai
    i3_theme 'adwaita-dark'
    sway_theme 'adwaita-dark'
    ;;
*)
    echo "Unsupported theme: $theme" 1>&2
    exit 1
    ;;
esac
