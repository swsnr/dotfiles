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

pkglists_to_remove=(cleanup)
pkglists_to_add=(base gnome)
trees_to_add=(base)
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
    pkglists_to_add+=("kastl")
    ;;
*RB*)
    pkglists_to_add+=("rb")
    trees_to_add+=("rb")
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

# Import our signing key into pacman's keyring
pacman-key -a "${DIR}/pacman-signing-key.asc"
pacman-key --lsign-key B8ADA38BC94C48C4E7AABE4F7548C2CC396B57FC

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

# Update mirror list before installing anything; we use the systemd service
# because it uses the appropriate reflector configuration.
if command -v reflector >/dev/null && [[ -e /etc/xdg/reflector/reflector.conf ]]; then
    systemctl start reflector.service || true
fi

pacman -Qtdq | pacman --noconfirm -Rs - || true
# Update the system, then install new packages and optional dependencies.
if [[ "${upgrade_packages}" == "true" ]]; then
    pacman -Syu
fi
pacman -S --needed "${packages_to_install[@]}"
pacman -S --needed --asdeps "${packages_to_install_optdeps[@]}"
pacman -D --asdeps "${packages_to_install_optdeps[@]}"

# Remove unused local pacman repos
for name in abs aur; do
    if [[ -d "/srv/pkgrepo/${name}" ]]; then
        btrfs subvolume delete "/srv/pkgrepo/${name}"
    fi
done

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

# See /usr/share/factory/etc/nsswitch.conf for the Arch Linux factory defaults.
# We add mdns hostnames (from Avahi) and libvirtd names, and also shuffle things around
# to follow the recommendations in nss-resolve(8) which Arch Linux deliberately doesn't
# do by default, see e.g. https://bugs.archlinux.org/task/57852
NSS_HOSTS=(
    # Resolves containers managed by systemd-machined
    mymachines
    # Resolve everything else with systemd-resolved and bail out if resolved
    # doesn't find hostname.  Everything after this stanza is just fallback in
    # case resolved is down
    resolve '[!UNAVAIL=return]'
    # Resolve hosts from /etc/hosts (systemd-resolved handles /etc/hosts as well
    # so this comes after resolve)
    files
    # Resolves gethostname(), i.e. /etc/hostname
    myhostname
    # Resolves from DNS
    dns
)
sed -i '/^hosts: /s/^hosts: .*/'"hosts: ${NSS_HOSTS[*]}/" /etc/nsswitch.conf

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
