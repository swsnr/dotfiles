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

# Setup for my private systems

set -xeuo pipefail

if [[ $EUID != 0 ]]; then
    echo 'Elevating privileges'
    exec sudo --preserve-env=AUR_PAGER,PACKAGER,EDITOR "$0" "$@"
fi

if [[ "${HOSTNAME}" != *kastl ]]; then
    echo "This is not a kastl host"
    exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}")"  >/dev/null 2>&1 && pwd)"

install -D -m644 "$DIR/etc/systemd/system/btrfs-scrub-io.conf" \
    "/etc/systemd/system/btrfs-scrub@.service.d/lunaryorn-kastl-limit-io.conf"

packages=(
  digikam # Digital photos
  gnucash # Personal finances
  gnucash-docs
  picard # Audio tag editor
)
pacman -Syu --needed "${packages[@]}"

# Install some personal flatpaks
flatpaks=(
    com.skype.Client # Sadly necessary
    org.jitsi.jitsi-meet # Secure video chats
    com.github.geigi.cozy # Audiobook player
    re.chiaki.Chiaki # PSN remote play client
    com.valvesoftware.Steam # Gaming
    de.bund.ausweisapp.ausweisapp2 # e-ID
)

flatpak install --system --or-update --noninteractive "${flatpaks[@]}"

aur_packages=(
    # CLI for 1password
    1password-cli
    # Connect phone and desktop system
    gnome-shell-extension-gsconnect
)

aur_optdeps=()

if [[ -n "${SUDO_USER:-}" ]]; then
    # Build AUR packages and install them
    if [[ ${#aur_packages} -gt 0 ]]; then
        sudo -u "$SUDO_USER" --preserve-env=AUR_PAGER,PACKAGER,EDITOR aur sync -daur -cRT "${aur_packages[@]}" "${aur_optdeps[@]}"
        pacman --needed -Syu "${aur_packages[@]}"
    fi
    if [[ ${#aur_optdeps[@]} -gt 0 ]]; then
        pacman --needed -S --asdeps "${aur_optdeps[@]}"
        pacman -D --asdeps "${aur_optdeps[@]}"
    fi
fi
