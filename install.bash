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
ln -fs -t ~/.local/bin/ "$DIR/bin/"*

# Environment variables
mkdir -p ~/.config/environment.d
ln -fs -t ~/.config/environment.d "$DIR"/environment/*.conf
clean-recursively ~/.config/environment.d

# Fish shell config files and functions
mkdir -p ~/.config/fish/functions ~/.config/fish/conf.d
ln -fs -t ~/.config/fish "$DIR/fish/config.fish"
ln -fs -t ~/.config/fish/functions "$DIR/fish/functions/"*.fish
ln -fs -t ~/.config/fish/conf.d "$DIR/fish/conf.d/"*.fish
clean-recursively ~/.config/fish/functions ~/.config/fish/conf.d
# Fish plugins (per fisher scheme)
ln -fs -t ~/.config/fish/conf.d "$DIR"/fish/plugins/*/conf.d/*.fish
ln -fs -t ~/.config/fish/functions "$DIR"/fish/plugins/*/functions/*.fish
ln -fs -t ~/.config/fish/completions "$DIR"/fish/plugins/*/completions/*.fish
# Remove fisher
rm -f ~/.config/fish/functions/fisher.fish ~/.config/fish/completions/fisher.fish

# Vim
ln -fs "$DIR/vim/ideavimrc" ~/.ideavimrc

# Neovim
mkdir -p ~/.config/nvim/lua/user
ln -fs -t ~/.config/nvim "$DIR"/neovim/init.lua
ln -fs -t ~/.config/nvim/lua/user "$DIR"/neovim/plugins.lua

# Git configuration
mkdir -p ~/.config/git
ln -fs -t ~/.config/git "$DIR/git/common/"*
ln -fs -t ~/.config/git "$DIR/git/config.linux"

# SSH configuration
mkdir -p ~/.ssh
mkdir -p ~/.ssh/{config.d,known-hosts}
chmod 0700 ~/.ssh ~/.ssh/{config.d,known-hosts}
ln -fs "$DIR/ssh/config" ~/.ssh/config
ln -fs -t ~/.ssh/known-hosts "$DIR/ssh/known-hosts/"*
ln -fs -t ~/.ssh/config.d "$DIR/ssh/config.d/"*
clean-recursively ~/.ssh/config.d ~/.ssh/known-hosts

# Scala configuration
mkdir -p ~/.ammonite ~/.sbt/1.0/plugins/project
ln -fs "$DIR/scala/ammonite-predef.sc" ~/.ammonite/predef.sc
ln -fs "$DIR/scala/settings.sbt" ~/.sbt/1.0/settings.sbt
ln -fs -t ~/.sbt/1.0/plugins "$DIR/scala/"{plugins,sbt-updates}.sbt
ln -fs -t ~/.sbt/1.0/plugins/project/ "$DIR/scala/sbt-updates.sbt"

# Misc files
mkdir -p ~/.config/{bat,latexmk,wezterm,restic}
ln -fs "$DIR/latex/latexmkrc" ~/.config/latexmk/latexmkrc
ln -fs "$DIR/misc/bat" ~/.config/bat/config
ln -fs "$DIR/misc/wezterm.lua" ~/.config/wezterm/wezterm.lua
ln -fs "$DIR/backup/linux.exclude" ~/.config/restic/linux.exclude
ln -fs "$DIR/misc/XCompose" ~/.XCompose

# Gnome
mkdir -p ~/.local/share/gnome-shell/extensions
ln -fs -t ~/.local/share/gnome-shell/extensions "$DIR/gnome/extensions/home@swsnr.de"
mkdir -p ~/.local/share/nautilus-python/extensions
ln -fs -t ~/.local/share/nautilus-python/extensions "$DIR/gnome/wezterm-nautilus.py"
"$DIR/gnome/settings.py"

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

# Flatpak setup
command -v flatpak >& /dev/null &&
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
