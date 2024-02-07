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

FONT='https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf'

has() {
    command -v "$1" >&/dev/null
}

packages=(
    nala

    # Shell & tools
    fish
    zoxide
    bat
    ripgrep
    eza
    file

    # Git
    git

    # Editor
    helix

    # Compiler & devtools
    clang
    shfmt
    shellcheck
    jq
    nodejs

    # Networking & cryptography
    rclone
    xh
    openssh
)

packages_to_remove=()

# Setup mirros and install packages
# shellcheck disable=SC2154 # Prefix comes from termux
MIRROR="${PREFIX}/etc/termux/mirrors/europe"
if [[ -e "${MIRROR}" ]]; then
    # /etc/termux sometimes doesn't exist on first bootstrap, so only install
    # mirrors if they exist.
    ln -sf "${MIRROR}" "${PREFIX}/etc/termux/chosen_mirrors"
fi

# Install nala if not yet there
if ! has nala; then
    pkg update
    pkg install nala
fi

nala upgrade --update --simple --assume-yes
nala install --no-update --simple --assume-yes "${packages[@]}"
for package in "${packages_to_remove[@]}"; do
    nala purge "${package}"
done

# Configure termux
install -pm644 -t"${HOME}/.termux/" \
    "${DIR}/termux.properties" "${DIR}/colors.properties"
if [[ ! -f "${HOME}/.termux/font.ttf" ]]; then
    curl -fsSL -o "${HOME}/.termux/.font.ttf.partial" "${FONT}"
    mv "${HOME}/.termux/.font.ttf.partial" "${HOME}/.termux/font.ttf"
fi
termux-reload-settings
