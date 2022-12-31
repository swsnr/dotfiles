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

FONT='https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/JetBrainsMono/Ligatures/Regular/complete/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete%20Mono.ttf?raw=true'

packages=(
    # Shell & tools
    fish
    zoxide
    bat
    ripgrep
    exa
    rclone
    xh
    file
    # Git
    git
    # Editor
    neovim
    # Compiler & devtools
    clang
    shfmt
    shellcheck
    jq
)

# Setup mirros and install packages
ln -sf "$PREFIX/etc/termux/mirrors/europe" "$PREFIX/etc/termux/chosen_mirrors"

pkg update
pkg upgrade
pkg install "${packages[@]}"

# Configure termux
install -pm644 -t"$HOME/.termux/" "$DIR/colors.properties"
if [[ ! -f "$HOME/.termux/font.ttf" ]]; then
    curl -fsSL -o "$HOME/.termux/.font.ttf.partial" "$FONT"
    mv "$HOME/.termux/.font.ttf.partial" "$HOME/.termux/font.ttf"
fi
termux-reload-settings
