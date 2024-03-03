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

# Install my basic Arch system

set -xeuo pipefail

PS4='\033[32m$(date +%H:%M:%S) >>>\033[0m '

if [[ "${EUID}" != 0 ]]; then
    echo 'Elevating privileges'
    exec sudo "$0" "$@"
fi

# My user account, to access the home directory and to discard privileges in
# order to call aurutils.
if [[ -n "${SUDO_USER:-}" ]]; then
    MY_USER_ACCOUNT="${SUDO_USER}"
elif [[ -n "${PKEXEC_UID:-}" ]]; then
    MY_USER_ACCOUNT="$(id -nu "${PKEXEC_UID}")"
else
    MY_USER_ACCOUNT=""
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

PRODUCT_NAME="$(</sys/class/dmi/id/product_name)"

# Whether to upgrade packages.  Set to false to avoid an initial pacman -Syu
upgrade_packages=true

# By default, do not use the proprietary nvidia driver
use_nvidia=false

# Configure secureboot if secureboot keys exist
use_secureboot=false
if command -v sbctl >/dev/null && [[ -f /usr/share/secureboot/keys/db/db.key ]]; then
    use_secureboot=true
fi

# Files and directories we'd explicitly like to remove from the root filesystem,
# using rm -rf
files_to_remove=(
    # Split into core and extra
    /etc/pacman.d/repos/50-core-repositories.conf
)

# Package lists which we'd like to remove and install respectively.
# We load package lists from bash files in pkglists/
pkglists_to_remove=(cleanup)
pkglists_to_add=(base 1password)
# Filesystem trees we'd like to copy to and delete from the root filesystem.
# Trees are directory structures and files under trees/
trees_to_add=(base 1password)
trees_to_remove=()

case "${PRODUCT_NAME}" in
'XPS 9315')
    pkglists_to_add+=("intel")
    trees_to_add+=("intel")
    ;;
*) ;;
esac

case "${HOSTNAME}" in
*kastl*)
    pkglists_to_add+=("gnome" "kastl")
    trees_to_add+=("gnome")
    ;;
*RB*)
    pkglists_to_add+=("gnome" "rb")
    trees_to_add+=("gnome" "rb")
    ;;
arch-test-kde*)
    pkglists_to_remove+=("gnome")
    trees_to_remove+=("gnome")
    trees_to_add+=("kde" "testing")
    pkglists_to_add+=("kde")
    ;;
arch-test*)
    # Enable testing repos on test VMs
    trees_to_add+=("testing")
    ;;
*) ;;
esac

# Setup proprietary nvidia driver if enabled
if [[ "${use_nvidia}" == true ]]; then
    pkglists_to_add+=("nvidia")
    trees_to_remove+=("kms")
    trees_to_add+=("nvidia")
else
    pkglists_to_remove+=("nvidia")
    trees_to_remove+=("nvidia")
    trees_to_add+=("kms")
fi

# Configure secure boot if enabled
if [[ "${use_secureboot}" == true ]]; then
    trees_to_add+=(secureboot)
else
    trees_to_remove+=(secureboot)
fi

# Support for VMs
chassis="$(hostnamectl chassis)"
if [[ "${chassis}" == "vm" ]]; then
    trees_to_add+=("vm-guest")
    pkglists_to_add+=("vm-guest")
fi

function add_tree() {
    local tree="$1"
    cp --recursive --no-dereference --preserve=links,mode,timestamps \
        --target-directory=/ --update --verbose \
        "${DIR}/trees/${tree}/."
}

function remove_tree() {
    local tree="$1"
    find "${DIR}/trees/${tree}" '!' -type d \
        -exec realpath --no-symlinks --relative-base="${DIR}/trees/${tree}" {} \; |
        xargs -n1 printf "/%s\0" | xargs -0 rm -vfd
}

# Cleanup files
if [[ 0 -lt "${#files_to_remove[@]}" ]]; then
    rm -rfv "${files_to_remove[@]}"
fi

# Add our filesystem trees
for tree in "${trees_to_add[@]}"; do
    echo "Adding filesystem tree ${tree}"
    add_tree "${tree}"
done

for tree in "${trees_to_remove[@]}"; do
    echo "Removing filesystem tree ${tree}"
    remove_tree "${tree}"
done

# Correct permissions
chmod 750 /etc/sudoers.d
find /etc/sudoers.d -type f -exec chmod 600 {} \+

# Decrypt private repo
if [[ ! -e /etc/pacman.d/repos/35-1password.conf && -e /etc/pacman.d/repos/35-1password.conf.gpg ]]; then
    gpg --no-symkey-cache --decrypt \
        --output /etc/pacman.d/repos/35-1password.conf \
        /etc/pacman.d/repos/35-1password.conf.gpg
fi

# Import keys for additional repos into pacman
pacman-key -a "${DIR}/pacman-keys/"*.gpg
pacman_keys=(
    'FCADAFC81273B9E7F184F2B0826659A9013E5B65' # openSUSE_Tools_key
    '42D80446DC5C2B66D69DF5B6C1A96AD497928E88' # home:swsnr OBS repo (my own packages)
    'B0D22477C20E1CA6814B8DAAE4ED3D2BB799BE2F' # My personal makepkg key (mostly for 1password packages)
)
for key in "${pacman_keys[@]}"; do
    pacman-key --lsign-key "${key}"
done
# Remove signing key for my old local repository
pacman-key --delete B8ADA38BC94C48C4E7AABE4F7548C2CC396B57FC || true

# Load and apply package lists
packages_to_install=()
packages_to_install_optdeps=()
packages_to_remove=()
flatpaks_to_install=()
flatpaks_to_remove=()

function load_pkglist() {
    local packages
    local optdeps
    local flatpaks
    packages=()
    optdeps=()
    flatpaks=()
    # shellcheck disable=SC1090
    source "${DIR}/pkglists/$2.bash"
    case "$1" in
    add)
        packages_to_install+=("${packages[@]}")
        packages_to_install_optdeps+=("${optdeps[@]}")
        flatpaks_to_install+=("${flatpaks[@]}")
        ;;
    remove)
        packages_to_remove+=("${optdeps[@]}")
        packages_to_remove+=("${packages[@]}")
        flatpaks_to_remove+=("${flatpaks[@]}")
        ;;
    *)
        return 1
        ;;
    esac
}

for item in "${pkglists_to_add[@]}"; do
    load_pkglist add "${item}"
done

for item in "${pkglists_to_remove[@]}"; do
    load_pkglist remove "${item}"
done

# Remove packages one by one because pacman doesn't handle uninstalled packages
# gracefully
for pkg in "${packages_to_remove[@]}"; do
    if pacman -Qi "${pkg}" &>/dev/null; then
        pacman --noconfirm -Rs "${pkg}"
    fi
done

pacman -Qtdq | pacman --noconfirm -Rs - || true
# Update the system, then install new packages and optional dependencies.
if [[ "${upgrade_packages}" == "true" ]]; then
    pacman -Syu
fi
pacman -S --needed "${packages_to_install[@]}"
pacman -S --needed --asdeps "${packages_to_install_optdeps[@]}"
pacman -D --asdeps "${packages_to_install_optdeps[@]}"

# Configure flatpak languages to install in addition to system locale
flatpak config --system --set extra-languages 'en;en_GB;de;de_DE'
# Install all flatpaks
flatpak install --system --noninteractive flathub "${flatpaks[@]}"
# Remove unused flatpaks; one by one because uninstall fails on missing refs :|
for flatpak in "${flatpaks_to_remove[@]}"; do
    flatpak uninstall --system --noninteractive "${flatpak}" || true
done
flatpak uninstall --system --noninteractive --unused
flatpak update --system --noninteractive
#endregion

# Update systemd preset to enable/disable services
systemctl preset-all

if [[ -n "${MY_USER_ACCOUNT}" ]]; then
    # Scrub home directory of my user account
    # TODO: Move this to a generated preset file
    instance="$(systemd-escape -p "/home/${MY_USER_ACCOUNT}")"
    systemctl enable "btrfs-scrub@${instance}.timer"
fi

# Mask a few services I don't want
systemctl mask passim.service # Caching daemon from fwupd

# Locale settings
localectl set-locale de_DE.UTF-8
# --no-convert stops localectl from trying to apply the text console layout to
# X11/Wayland and vice versa
localectl set-keymap --no-convert us
localectl set-x11-keymap --no-convert us,de pc105 '' ,compose:ralt

#region Firewall setup
# Start firewalld and configure it
systemctl start firewalld.service
firewall-cmd --quiet --permanent --zone=home \
    --add-service=upnp-client \
    --add-service=rdp \
    --add-service=ssh \
    --add-service=syncthing \
    --add-service=mdns \
    --add-service=samba-client
firewall-cmd --quiet --permanent --zone=work \
    --add-service=rdp \
    --add-service=ssh \
    --add-service=mdns \
    --add-service=samba-client
if [[ "${HOSTNAME}" == *kastl* ]]; then
    # Define a service for PS remote play
    firewall-cmd --quiet --permanent --new-service=ps-remote-play || true
    firewall-cmd --quiet --permanent --service=ps-remote-play --set-short='PS Remote Play' || true
    firewall-cmd --quiet --permanent --service=ps-remote-play --add-port=9302/udp
    firewall-cmd --quiet --permanent --service=ps-remote-play --add-port=9303/udp
    firewall-cmd --quiet --permanent --zone=home --add-service=ps-remote-play

    # Allow gsconnect access
    firewall-cmd --quiet --permanent --zone=home --add-service=gsconnect || true
fi
# Don't allow incoming SSH connections on public networks (this is a weird
# default imho).
firewall-cmd --quiet --permanent --zone=public --remove-service=ssh
firewall-cmd --quiet --reload
#endregion

#region Secure boot setup
# Setup secure boot
if [[ "${use_secureboot}" == true ]]; then
    # Generate signed bootloader image
    if ! sbctl list-files | grep -q /usr/lib/systemd/boot/efi/systemd-bootx64.efi; then
        sbctl sign -s -o /usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed /usr/lib/systemd/boot/efi/systemd-bootx64.efi
        bootctl update --graceful
    fi

    # Generate signed firmware updater
    if ! sbctl list-files | grep -q /usr/lib/fwupd/efi/fwupdx64.efi; then
        sbctl sign -s -o /usr/lib/fwupd/efi/fwupdx64.efi.signed /usr/lib/fwupd/efi/fwupdx64.efi
    fi

    sbctl sign-all
    sbctl verify # Safety check
fi
#endregion

# Install or update, and then configure the bootloader.
# Do this AFTER signing the boot loader with sbctl, see above, to make sure we
# install the signed loader.
if ! [[ -e /efi/EFI/BOOT/BOOTX64.EFI ]]; then
    bootctl install
else
    bootctl update --graceful
fi
