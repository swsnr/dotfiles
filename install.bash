#!/usr/bin/bash
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

PS4='\033[32m$(date +%H:%M:%S) >>>\033[0m '

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

clean-recursively() {
    find "$@" -xtype l -delete
}

has() {
    command -v "$1" >&/dev/null
}

# Cleanup things I no longer use
rm -rf ~/.config/micro

# Set up pre-commit hook for this repo
ln -fs "../../pre-commit" "${DIR}/.git/hooks/pre-commit"

# Binaries
mkdir -p ~/.local/bin
clean-recursively ~/.local/bin
ln -fs -t ~/.local/bin/ "${DIR}/bin/"*

# Experimental thin client for SBT, to connect to running servers
if [[ -e /usr/share/sbt/bin/sbtn-x86_64-pc-linux ]]; then
    ln -fs /usr/share/sbt/bin/sbtn-x86_64-pc-linux ~/.local/bin/sbtn
fi

# Environment variables
mkdir -p ~/.config/environment.d
ln -fs -t ~/.config/environment.d "${DIR}"/environment/*.conf
clean-recursively ~/.config/environment.d || true

# Fish shell config files and functions
mkdir -p ~/.config/fish/functions ~/.config/fish/conf.d
ln -fs -t ~/.config/fish "${DIR}/fish/config.fish"
ln -fs -t ~/.config/fish/functions "${DIR}/fish/functions/"*.fish
ln -fs -t ~/.config/fish/conf.d "${DIR}/fish/conf.d/"*.fish
clean-recursively ~/.config/fish/functions ~/.config/fish/conf.d ~/.config/fish/completions || true
if has broot; then
    # Tell broot that its shell function is installed
    broot --set-install-state installed
fi

# Remove profile.  I set up environment variables through systemd, so let's
# clear profile files from distributions, etc. which mess up my $PATH.
rm -f ~/.profile

# Bash configuration.  I prefer fish but if it's not available bash is the
# fallback, but its default settings are unbearable.  Also make sure we have no
# custom profile; some tools (JetBrains toolbox, looking at you) think it's a
# good idea to mess with the profile files in order to override $PATH.
for file in bashrc bash_logout bash_profile; do
    ln -fs "${DIR}/bash/${file}" "${HOME}/.${file}"
done

# Termux has no systemd, so let's guard these services
if has systemctl; then
    # Install user services to local systemd directory
    mkdir -p ~/.local/share/systemd/user
    ln -fs -t ~/.local/share/systemd/user "${DIR}/systemd/swsnr-color-scheme-hook.service"
    # Remove old services
    rm -f ~/.config/systemd/user/{color-scheme-hook,ssh-agent}.service
    # Reload daemon and enable relevant services
    systemctl --user daemon-reload
    systemctl --user enable swsnr-color-scheme-hook.service
fi

# Terminal emulator
mkdir -p ~/.config/wezterm/colors
ln -fs "${DIR}/wezterm/wezterm.lua" ~/.config/wezterm/wezterm.lua
clean-recursively ~/.config/wezterm/colors || true

# Helix
mkdir -p ~/.config/helix/themes
ln -fs -t ~/.config/helix "${DIR}/helix/"{config,languages}.toml
if [[ ! -e ~/.config/helix/themes/swsnr-light-dark.toml ]]; then
    ln -fs /usr/lib/helix/runtime/themes/onelight.toml ~/.config/helix/themes/swsnr-light-dark.toml
fi

# Git configuration
mkdir -p ~/.config/git
ln -fs -t ~/.config/git "${DIR}/git/common/"*
ln -fs -t ~/.config/git "${DIR}/git/config.linux"

# SSH configuration
mkdir -p ~/.ssh
mkdir -p ~/.ssh/{config.d,known-hosts.d}
chmod 0700 ~/.ssh ~/.ssh/{config.d,known-hosts.d}
ln -fs "${DIR}/ssh/config" ~/.ssh/config
ln -fs -t ~/.ssh/known-hosts.d "${DIR}/ssh/known-hosts.d/"*
ln -fs -t ~/.ssh/config.d "${DIR}/ssh/config.d/"*
clean-recursively ~/.ssh/config.d ~/.ssh/known-hosts.d || true

# Make IDEA download its JDKs to ~/.local/share/jdks
mkdir -p ~/.local/share/jdks
ln -fs -T .local/share/jdks ~/.jdks

# Scala configuration
mkdir -p ~/.ammonite ~/.sbt/1.0/plugins/project
ln -fs "${DIR}/scala/ammonite-predef.sc" ~/.ammonite/predef.sc
ln -fs "${DIR}/scala/settings.sbt" ~/.sbt/1.0/settings.sbt
ln -fs -t ~/.sbt/1.0/plugins "${DIR}/scala/"{plugins,sbt-updates}.sbt
ln -fs -t ~/.sbt/1.0/plugins/project/ "${DIR}/scala/sbt-updates.sbt"
ln -fs -t ~/.sbt "${DIR}/scala/sbtopts"

# k8s and related tools
mkdir -p ~/.config/k9s
ln -fs -t ~/.config/k9s "${DIR}/k8s/k9s/skins" ~/.config/k9s
# Default k9s skin
ln -fs ./skins/transparent.yml ~/.config/k9s/skin.yml

# GPG
mkdir -p ~/.gnupg
clean-recursively ~/.gnupg || true
ln -fs -t ~/.gnupg "${DIR}/gnupg/"*.conf

# bat viewer
mkdir -p ~/.config/bat/themes
ln -fs "${DIR}/bat/config" ~/.config/bat/config
ln -fs -t ~/.config/bat/themes "${DIR}/bat/"*.tmTheme
clean-recursively ~/.config/bat/themes
has bat && bat cache --build

# Python
mkdir -p ~/.config/python
# Personal startup file, see environment/50-python.conf
ln -fs "${DIR}/python/startup.py" ~/.config/python/startup.py

# Pipewire
mkdir -p ~/.config/pipewire/pipewire.conf.d/
clean-recursively ~/.config/pipewire/pipewire.conf.d/

# Misc files
mkdir -p ~/.config/{latexmk,restic,zim}
ln -fs "${DIR}/backup/linux.exclude" ~/.config/restic/linux.exclude
ln -fs "${DIR}/latex/latexmkrc" ~/.config/latexmk/latexmkrc
ln -fs "${DIR}/misc/XCompose" ~/.XCompose
ln -fs "${DIR}/misc/gamemode.ini" ~/.config/gamemode.ini
ln -fs "${DIR}/misc/zim-style.conf" ~/.config/zim/style.conf
# Electron flags for all electron versions
#
# We use the following flags:
#
# --ozone-platform-hint=auto enables wayland support in wayland environments
# --enable-features=WaylandWindowDecorations adds client-side decorations under wayland
# --disable-features=WaylandFractionalScaleV1 works around blurry text, see https://github.com/microsoft/vscode/issues/192590
# --enable-webrtc-pipewire-capturer enables screen capture with pipewire under wayland
for electron_version in "" 24 25; do
    ln -fs "${DIR}/misc/electron-flags.conf" \
        ~/.config/electron"${electron_version}"-flags.conf
done
# Remove outdated electron flags
rm -f ~/.config/electron{19,21,22,23}-flags.conf

# devhelp
# mutter-docs ships documentation at wrong place, so we have to manually symlink
# it to make it appear in devhelp, see https://bugs.archlinux.org/task/79860
mkdir -p ~/.local/share/devhelp/books
ln -fs -t ~/.local/share/devhelp/books \
    /usr/share/mutter-12/doc/{cally,clutter,cogl,cogl-pango,meta}

case "${XDG_CURRENT_DESKTOP:-}" in
GNOME)
    "${DIR}/gnome/settings.py" || true

    # Disable kwallet in Gnome
    ln -fs "${DIR}/gnome/kwalletrc" ~/.config/kwalletrc
    # Disable our SSH agent service; Gnome includes an SSH agent as part of its
    # keyring service.
    systemctl --user disable ssh-agent.service || true

    # Local gnome extensions
    mkdir -p ~/.local/share/gnome-shell/extensions
    ln -fs -t ~/.local/share/gnome-shell/extensions \
        "${DIR}/gnome/extensions/home@swsnr.de" \
        "${DIR}/gnome/extensions/spacetimeformats@swsnr.de" \
        "${DIR}/gnome/extensions/disable-extension-updates@swsnr.de"
    clean-recursively ~/.local/share/gnome-shell/extensions/

    extensions=(
        # Add a systray and a drive menu to the panel
        'appindicatorsupport@rgcjonas.gmail.com'
        'drive-menu@gnome-shell-extensions.gcampax.github.com'
        # Disable automatic extension updates; I install all extensions through
        # pacman. This stops Gnome from sending the list of my extensions to
        # extensions.gnome.org.
        'disable-extension-updates@swsnr.de'
        # Cool wallpapers every day
        'nasa_apod@elinvention.ovh'
        # Inhibit suspend
        'caffeine@patapon.info'
    )
    case "${HOSTNAME}" in
    *kastl*)
        extensions+=(
            # Connect my system to my mobile phone
            'gsconnect@andyholmes.github.io'
        )
        ;;
    *RB*)
        extensions+=(
            'utc-clock@swsnr.de'
        )
        ;;
    *) ;;
    esac

    if has gnome-extensions; then
        for extension in "${extensions[@]}"; do
            # Enable extension if present
            if gnome-extensions list | grep -q "${extension}"; then
                gnome-extensions enable "${extension}"
            fi
        done
    fi
    ;;
KDE)
    if test -L ~/.config/kwalletrc; then
        rm ~/.config/kwalletrc
    fi

    # Synchronize KDE plasma environment with systemd's environment
    # For some reason plasma does not inherit the systemd user environment
    # properly, and thus has a wrong $PATH.  We add a little hack to synchronize
    # both environments.
    mkdir -p ~/.config/plasma-workspace/env
    ln -fs "${DIR}/kde/systemd-fix-env.sh" ~/.config/plasma-workspace/env/systemd-fix-env.sh

    # Configure KDE and its applications
    "${DIR}/kde/settings.py"

    # Enable SSH agent service, because KDE doesn't include an agent
    systemctl --user enable ssh-agent.socket
    ;;
*) ;;
esac

# Generate additional fish completions
mkdir -p ~/.config/fish/completions
has rclone && rclone completion fish ~/.config/fish/completions/rclone.fish
has restic && restic generate --fish-completion ~/.config/fish/completions/restic.fish

# Setup firefox user.js
if has python && [[ -e ~/.mozilla/firefox/profiles.ini ]]; then
    python <<'EOF' | xargs -0 -n1 ln -sf "${DIR}"/misc/user.js || true
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

if has syncthing && [[ "${HOSTNAME}" == *kastl* ]]; then
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

# Configure Code OSS
has code && "${DIR}"/misc/code-settings.py

case "${HOSTNAME}" in
*kastl*)
    # On personal systems use 1password for SSH and commit signing, so disable
    # the SSH agent service and configure SSH to talk to 1password instead.
    systemctl --user disable ssh-agent.service || true
    ln -fs -t ~/.config/git "${DIR}/git/config.1password-signing"
    # This file deliberately lies outside of "${DIR}/ssh/config.d" because we
    # install all files from config.d above
    ln -fs -t ~/.ssh/config.d "${DIR}/ssh/90-1password-ssh-agent"
    ;;
*) ;;
esac
