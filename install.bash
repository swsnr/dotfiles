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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}")"  >/dev/null 2>&1 && pwd)"

clean-recursively() {
    find "$@" -xtype l -delete
}

# Binaries
mkdir -p ~/.local/bin
clean-recursively ~/.local/bin
ln -fs -t ~/.local/bin/ "$DIR/bin/"*

# Environment variables
mkdir -p ~/.config/environment.d
ln -fs -t ~/.config/environment.d "$DIR"/environment/*.conf
clean-recursively ~/.config/environment.d || true

# Fish shell config files and functions
mkdir -p ~/.config/fish/functions ~/.config/fish/conf.d
ln -fs -t ~/.config/fish "$DIR/fish/config.fish"
ln -fs -t ~/.config/fish/functions "$DIR/fish/functions/"*.fish
ln -fs -t ~/.config/fish/conf.d "$DIR/fish/conf.d/"*.fish
clean-recursively ~/.config/fish/functions ~/.config/fish/conf.d || true
# Fish plugins (per fisher scheme)
ln -fs -t ~/.config/fish/conf.d "$DIR"/fish/plugins/*/conf.d/*.fish
ln -fs -t ~/.config/fish/functions "$DIR"/fish/plugins/*/functions/*.fish
ln -fs -t ~/.config/fish/completions "$DIR"/fish/plugins/*/completions/*.fish
# Remove fisher
rm -f ~/.config/fish/functions/fisher.fish ~/.config/fish/completions/fisher.fish

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

# Vim
ln -fs "$DIR/vim/ideavimrc" ~/.ideavimrc

# Neovim
mkdir -p ~/.config/nvim/lua/
ln -fs -t ~/.config/nvim "$DIR"/neovim/init.lua
clean-recursively ~/.config/nvim/lua || true
ln -fs -t ~/.config/nvim/lua "$DIR"/neovim/lua/swsnr

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

# Scala configuration
mkdir -p ~/.ammonite ~/.sbt/1.0/plugins/project
ln -fs "$DIR/scala/ammonite-predef.sc" ~/.ammonite/predef.sc
ln -fs "$DIR/scala/settings.sbt" ~/.sbt/1.0/settings.sbt
ln -fs -t ~/.sbt/1.0/plugins "$DIR/scala/"{plugins,sbt-updates}.sbt
ln -fs -t ~/.sbt/1.0/plugins/project/ "$DIR/scala/sbt-updates.sbt"

# GPG
mkdir -p ~/.gnupg
clean-recursively ~/.gnupg || true
ln -fs -t ~/.gnupg "$DIR/gnupg/"*.conf

# Python
mkdir -p ~/.config/python
# Personal startup file, see environment/50-python.conf
ln -fs "$DIR/python/startup.py" ~/.config/python/startup.py

# Misc files
mkdir -p ~/.config/{bat,latexmk,wezterm,restic}
ln -fs "$DIR/backup/linux.exclude" ~/.config/restic/linux.exclude
ln -fs "$DIR/latex/latexmkrc" ~/.config/latexmk/latexmkrc
ln -fs "$DIR/misc/bat" ~/.config/bat/config
ln -fs "$DIR/misc/wezterm.lua" ~/.config/wezterm/wezterm.lua
ln -fs "$DIR/misc/XCompose" ~/.XCompose
ln -fs "$DIR/misc/electron-flags.conf" ~/.config/electron-flags.conf
ln -fs "$DIR/misc/electron-flags.conf" ~/.config/electron17-flags.conf
ln -fs "$DIR/misc/gamemode.ini" ~/.config/gamemode.ini

# Gnome
mkdir -p ~/.local/share/gnome-shell/extensions
ln -fs -t ~/.local/share/gnome-shell/extensions \
  "$DIR/gnome/extensions/home@swsnr.de" \
  "$DIR/gnome/extensions/spacetimeformats@swsnr.de" \
  "$DIR/gnome/extensions/touchpad-toggle@swsnr.de" \
  "$DIR/gnome/extensions/disable-extension-updates@swsnr.de"
clean-recursively ~/.local/share/nautilus-python/extensions || true
"$DIR/gnome/settings.py" || true

# Attempt to enable extensions; this will fail for extensions that were just
# installed, but we try nonetheless
gnome-extensions enable 'disable-extension-updates@swsnr.de' || true

# On personal systems use 1password for SSH and commit signing
if [[ "$HOSTNAME" == *kastl* ]]; then
  ln -fs -t ~/.config/git "$DIR/git/config.1password-signing"
  # This file deliberately lies outside of "$DIR/ssh/config.d" because we
  # install all files from config.d above
  ln -fs -t ~/.ssh/config.d "$DIR/ssh/90-1password-ssh-agent"
fi

# Generate additional fish completions
mkdir -p ~/.config/fish/completions
command -v rclone >& /dev/null &&
    rclone completion fish > ~/.config/fish/completions/rclone.fish
command -v restic >& /dev/null &&
    restic generate --fish-completion ~/.config/fish/completions/restic.fish
command -v tea >& /dev/null && tea autocomplete fish --install

# Install terminfo for wezterm
function install_wezterm_terminfo {
  if [[ ! -f ~/.terminfo/w/wezterm ]]; then
    local tempfile
    tempfile="$(mktemp)"
    trap 'rm -f -- "${tempfile}"' EXIT
    curl -o "$tempfile" https://raw.githubusercontent.com/wez/wezterm/master/termwiz/data/wezterm.terminfo
    tic -x -o ~/.terminfo "$tempfile"
  fi
}
install_wezterm_terminfo

# Setup firefox user.js
python <<'EOF' | xargs -0 -n1 ln -sf "$DIR"/misc/user.js
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

# Flatpak setup
if command -v flatpak >& /dev/null; then
    # Flathub and flathub beta
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak remote-add --user --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo

    # Gnome nightlies
    flatpak remote-add --user --if-not-exists gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo

    # Adapt filesystem permissions for Steam: Add access to downloads for backup
    # imports, but deny access to Music and Pictures
    flatpak override --user \
        --filesystem xdg-download:ro \
        --nofilesystem xdg-music \
        --nofilesystem xdg-pictures \
        com.valvesoftware.Steam

    # Reduce access of some apps which default to host access
    flatpak override --user \
        --nofilesystem host --filesystem ~/Hörbücher \
        com.github.geigi.cozy
    flatpak override --user \
        --nofilesystem host --filesystem xdg-music \
        org.nickvision.tagger

    # Remove overrides for chiaki; it now uses wayland natively.
    flatpak override --user --reset re.chiaki.Chiaki

    # Allow tellico to access my documents folder
    flatpak override --user \
        --filesystem xdg-documents \
        org.kde.tellico

    # Fix https://github.com/flathub/org.gnome.Lollypop/issues/109 and
    # https://gitlab.gnome.org/World/lollypop/-/issues/2892
    flatpak override --user \
        --filesystem=/tmp \
        org.gnome.Lollypop

    # Run JA2 on Wayland natively
    flatpak override --user \
        --socket=wayland --env=SDL_VIDEODRIVER=wayland \
        io.github.ja2-stracciatella
fi

# Configure Code OSS
command -v code >& /dev/null && ./misc/code-settings.py
