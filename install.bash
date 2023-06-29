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

set -xeuo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

clean-recursively() {
    find "$@" -xtype l -delete
}

has() {
    command -v "$1" >&/dev/null
}

# Binaries
mkdir -p ~/.local/bin
clean-recursively ~/.local/bin
ln -fs -t ~/.local/bin/ "$DIR/bin/"*

# Experimental thin client for SBT, to connect to running servers
if [[ -e /usr/share/sbt/bin/sbtn-x86_64-pc-linux ]]; then
    ln -fs /usr/share/sbt/bin/sbtn-x86_64-pc-linux ~/.local/bin/sbtn
fi

# Environment variables
mkdir -p ~/.config/environment.d
ln -fs -t ~/.config/environment.d "$DIR"/environment/*.conf
clean-recursively ~/.config/environment.d || true

# Fish shell config files and functions
mkdir -p ~/.config/fish/functions ~/.config/fish/conf.d
ln -fs -t ~/.config/fish "$DIR/fish/config.fish"
ln -fs -t ~/.config/fish/functions "$DIR/fish/functions/"*.fish
ln -fs -t ~/.config/fish/conf.d "$DIR/fish/conf.d/"*.fish
clean-recursively ~/.config/fish/functions ~/.config/fish/conf.d ~/.config/fish/completions || true
# Fish plugins (per fisher scheme)
ln -fs -t ~/.config/fish/conf.d "$DIR"/fish/plugins/*/conf.d/*.fish
ln -fs -t ~/.config/fish/functions "$DIR"/fish/plugins/*/functions/*.fish

# Remove profile.  I set up environment variables through systemd, so let's
# clear profile files from distributions, etc. which mess up my $PATH.
rm -f ~/.profile

# Bash configuration.  I prefer fish but if it's not available bash is the
# fallback, but its default settings are unbearable.  Also make sure we have no
# custom profile; some tools (JetBrains toolbox, looking at you) think it's a
# good idea to mess with the profile files in order to override $PATH.
for file in bashrc bash_logout bash_profile; do
    ln -fs "$DIR/bash/${file}" "${HOME}/.${file}"
done

# Terminal emulator
mkdir -p ~/.config/wezterm/colors
ln -fs "$DIR/wezterm/wezterm.lua" ~/.config/wezterm/wezterm.lua
clean-recursively ~/.config/wezterm/colors || true

# Helix
mkdir -p ~/.config/helix
ln -fs "$DIR/helix/config.toml" ~/.config/helix/config.toml

# Git configuration
mkdir -p ~/.config/git
ln -fs -t ~/.config/git "$DIR/git/common/"*
ln -fs -t ~/.config/git "$DIR/git/config.linux"

# SSH configuration
mkdir -p ~/.ssh
mkdir -p ~/.ssh/{config.d,known-hosts.d}
chmod 0700 ~/.ssh ~/.ssh/{config.d,known-hosts.d}
ln -fs "$DIR/ssh/config" ~/.ssh/config
ln -fs -t ~/.ssh/known-hosts.d "$DIR/ssh/known-hosts.d/"*
ln -fs -t ~/.ssh/config.d "$DIR/ssh/config.d/"*
clean-recursively ~/.ssh/config.d ~/.ssh/known-hosts.d || true

# Remove KDE leftovers
systemctl --user disable ssh-agent.service || true
rm -f  ~/.config/systemd/user/ssh-agent.service
systemctl --user daemon-reload
rm -rf ~/.config/plasma-workspace/ \
  ~/.config/kwinrc ~/.config/kwinrulesrc \
  ~/.config/kdeglobals ~/.config/kscreenlockerrc \
  ~/.config/kmail2rc ~/.config/akonadi* \
  ~/.local/share/baloo ~/.local/share/akonadi*

# Scala configuration
mkdir -p ~/.ammonite ~/.sbt/1.0/plugins/project
ln -fs "$DIR/scala/ammonite-predef.sc" ~/.ammonite/predef.sc
ln -fs "$DIR/scala/settings.sbt" ~/.sbt/1.0/settings.sbt
ln -fs -t ~/.sbt/1.0/plugins "$DIR/scala/"{plugins,sbt-updates}.sbt
ln -fs -t ~/.sbt/1.0/plugins/project/ "$DIR/scala/sbt-updates.sbt"
ln -fs -t ~/.sbt "$DIR/scala/sbtopts"

# k8s and related tools
mkdir -p ~/.config/k9s
ln -fs -t ~/.config/k9s "$DIR/k8s/k9s/skins" ~/.config/k9s
# Default k9s skin
ln -fs ./skins/transparent.yml ~/.config/k9s/skin.yml

# GPG
mkdir -p ~/.gnupg
clean-recursively ~/.gnupg || true
ln -fs -t ~/.gnupg "$DIR/gnupg/"*.conf

# bat viewer
mkdir -p ~/.config/bat/themes
ln -fs "$DIR/bat/config" ~/.config/bat/config
ln -fs -t ~/.config/bat/themes "$DIR/bat/"*.tmTheme
has bat && bat cache --build

# Python
mkdir -p ~/.config/python
# Personal startup file, see environment/50-python.conf
ln -fs "$DIR/python/startup.py" ~/.config/python/startup.py

# Pipewire
mkdir -p ~/.config/pipewire/pipewire.conf.d/
clean-recursively ~/.config/pipewire/pipewire.conf.d/

# Misc files
mkdir -p ~/.config/{latexmk,restic}
ln -fs "$DIR/backup/linux.exclude" ~/.config/restic/linux.exclude
ln -fs "$DIR/latex/latexmkrc" ~/.config/latexmk/latexmkrc
ln -fs "$DIR/misc/XCompose" ~/.XCompose
ln -fs "$DIR/misc/electron-flags.conf" ~/.config/electron-flags.conf
ln -fs "$DIR/misc/electron-flags.conf" ~/.config/electron19-flags.conf
ln -fs "$DIR/misc/electron-flags.conf" ~/.config/electron21-flags.conf
ln -fs "$DIR/misc/gamemode.ini" ~/.config/gamemode.ini
ln -fs "$DIR/misc/zim-style.conf" ~/.config/zim/style.conf
ln -fs "$DIR/misc/kwalletrc" ~/.config/kwalletrc

# Gnome settings
"$DIR/gnome/settings.py" || true
# Local gnome extensions
mkdir -p ~/.local/share/gnome-shell/extensions
ln -fs -t ~/.local/share/gnome-shell/extensions \
    "$DIR/gnome/extensions/home@swsnr.de" \
    "$DIR/gnome/extensions/spacetimeformats@swsnr.de" \
    "$DIR/gnome/extensions/disable-extension-updates@swsnr.de"
clean-recursively ~/.local/share/gnome-shell/extensions/

extensions=(
    # Extend top bar: Show removable drives, workspaces and systray
    'drive-menu@gnome-shell-extensions.gcampax.github.com'
    'workspace-indicator@gnome-shell-extensions.gcampax.github.com'
    # Disable automatic extension updates; I install all extensions through
    # pacman
    'disable-extension-updates@swsnr.de'
    # Better tiling
    'tiling-assistant@leleat-on-github'
    # Bling bling
    'burn-my-windows@schneegans.github.com'
    'gnome-shell-extension-desktop-cube'
    # Cool wallpapers every day
    'nasa_apod@elinvention.ovh'
)
case "$HOSTNAME" in
*kastl*)
    extensions+=(
        # Connect my system to my mobile phone
        'gsconnect@andyholmes.github.io'
        # Touch screen menus
        'flypie@schneegans.github.com'
    )
    ;;
esac
if has gnome-extensions; then
    for extension in "${extensions[@]}"; do
        # Enable extension if present
        if gnome-extensions list | grep -q "${extension}"; then
            gnome-extensions enable "${extension}"
        fi
    done
fi

# On personal systems use 1password for SSH and commit signing
if [[ "$HOSTNAME" == *kastl* ]]; then
    ln -fs -t ~/.config/git "$DIR/git/config.1password-signing"
    # This file deliberately lies outside of "$DIR/ssh/config.d" because we
    # install all files from config.d above
    ln -fs -t ~/.ssh/config.d "$DIR/ssh/90-1password-ssh-agent"
fi

# Generate additional fish completions
mkdir -p ~/.config/fish/completions
has rclone && rclone completion fish >~/.config/fish/completions/rclone.fish
has restic && restic generate --fish-completion ~/.config/fish/completions/restic.fish

# Setup firefox user.js
if has python && [[ -e ~/.mozilla/firefox/profiles.ini ]]; then
    python <<'EOF' | xargs -0 -n1 ln -sf "$DIR"/misc/user.js || true
from pathlib import Path
from configparser import ConfigParser
firefox = Path.home() / '.mozilla' / 'firefox'
config = ConfigParser()
config.read_string((firefox / 'profiles.ini').read_text())
paths = []
for section in config:
    if section.startswith('Profile'):
        path = config[section]['Path']
        user_js = Path(path) / 'user.js'
        if config[section].get('IsRelative', '0') == '1':
            paths.append(str(firefox / user_js))
        else:
            paths.append(str(user_js))
print('\0'.join(paths), end='')
EOF
fi

if has syncthing && [[ "$HOSTNAME" == *kastl* ]]; then
    systemctl --user enable --now syncthing.service
fi

# Flatpak setup
if has flatpak; then
    # Adapt filesystem permissions for Steam: Add access to downloads for backup
    # imports, but deny access to Music and Pictures
    flatpak override --user \
        --filesystem xdg-download:ro \
        --nofilesystem xdg-music \
        --nofilesystem xdg-pictures \
        com.valvesoftware.Steam
fi
