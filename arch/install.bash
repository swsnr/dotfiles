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

if [[ $EUID != 0 ]]; then
    echo 'Elevating privileges'
    exec sudo --preserve-env=AUR_PAGER,PACKAGER "$0" "$@"
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"



packages=(
    # Basic packages
    base
    dracut
    linux-firmware
    intel-ucode
    btrfs-progs
    linux
    linux-lts
    linux-headers
    linux-lts-headers
    lsb-release
    sudo
    efibootmgr
    # System monitoring
    powertop
    iotop
    htop
    lsof
    # System services
    fwupd
    # Networking
    networkmanager
    avahi
    nss-mdns
    # USB and USB storage file systems
    ntfs-3g
    exfat-utils
    usbutils
    # Arch tools & infrastructure
    archlinux-contrib
    pacman-contrib
    reflector
    pkgfile
    # Build packages
    base-devel
    namcap
    devtools
    aurpublish
    # Shell & tools
    man-db
    man-pages
    fish
    git
    toolbox
    neovim
    exa
    fd
    sd
    ripgrep
    bat
    mdcat
    nnn
    rsync
    curl
    p7zip
    zip
    jq
    pandoc
    shellcheck
    shfmt
    # Development tools
    code
    hub
    github-cli
    rustup
    hexyl
    oxipng
    cargo-audit
    cargo-outdated
    cargo-udeps
    # Containers, kubernetes & cloud
    podman
    toolbox
    kubectl
    helm
    hcloud
    # Desktop tools
    wl-clipboard
    dconf-editor
    # Desktop services
    xdg-user-dirs
    xdg-utils
    flatpak
    flatpak-builder
    pcsclite
    cups
    system-config-printer
    hplip
    bluez
    sane
    pipewire-pulse
    # Applications (only stuff that's not flatpaked)
    youtube-dl
    mediathekview
    # Latex
    texlive-most
    # Fonts
    noto-fonts
    noto-fonts-extra
    noto-fonts-emoji
    ttf-liberation
    ttf-caladea
    ttf-carlito
    ttf-cascadia-code
    ttf-fira-code
    ttf-fira-mono
    ttf-fira-sans
    adobe-source-code-pro-fonts
    adobe-source-sans-pro-fonts
    adobe-source-serif-pro-fonts
    ttf-roboto
    ttf-ubuntu-font-family
    ttf-fira-mono
    ttf-fira-sans
    # Themes
    papirus-icon-theme
    arc-gtk-theme
    # Gnome
    gdm
    gnome-characters
    gnome-keyring
    gnome-screenshot
    gnome-software
    gnome-shell
    gnome-shell-extensions
    gnome-system-monitor
    gnome-control-center
    gnome-terminal
    gnome-tweaks
    xdg-user-dirs-gtk
    file-roller
    yelp
    nautilus
    gvfs-afc
    gvfs-goa
    gvfs-google
    gvfs-gphoto2
    gvfs-mtp
    gvfs-nfs
    gvfs-smb
    sushi
    evince
    eog
    simple-scan
)

pacman -Syu --needed "${packages[@]}"

pacman -D --asdeps pipewire-pulse

optdeps=(
    # linux: wireless frequency policies
    crda
    # poppler: data files
    poppler-data
    # dracut: uefi support and stripping
    binutils
    elfutils
    # nb: rendered notes
    w3m
    # libva: intel drivers
    intel-media-driver
    # ripgrep-all: additional search adapters
    # tesseract
    # graphicsmagick
    # tesseract: data models
    # tesseract-data-deu
    # tesseract-data-eng
)

pacman -S --needed --asdeps "${optdeps[@]}"

# Desktop manager
systemctl enable gdm.service
# Periodically trim all filesystems
systemctl enable fstrim.timer
# Pacman cache cleanup and file database updates
systemctl enable paccache.timer
systemctl enable pkgfile-update.timer
# Look for firmware updates
systemctl enable fwupd-refresh.timer
# Periodic mirrorlist updates
install -Dpm644 "$DIR/etc/reflector.conf" /etc/xdg/reflector/reflector.conf
systemctl enable reflector.timer
# DNS stub daemon
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
install -Dpm644 "$DIR/etc/resolved-lunaryorn.conf" /etc/systemd/resolved.conf.d/50-lunaryorn.conf
systemctl enable systemd-resolved.service
systemctl restart systemd-resolved.service
# Time synchronization
install -Dpm644 "$DIR/etc/timesyncd-lunaryorn.conf" /etc/systemd/timesyncd.conf.d/50-lunaryorn.conf
systemctl enable systemd-timesyncd.service
systemctl restart systemd-timesyncd.service
# Networking
systemctl enable NetworkManager.service
systemctl enable avahi-daemon.service
# Printing and other desktop services
systemctl enable cups.service
systemctl enable bluetooth.service
# Smartcard services for ausweisapp2
systemctl enable pcscd.socket

if [[ ! -f /etc/subuid ]]; then touch /etc/subuid; fi
if [[ ! -f /etc/subgid ]]; then touch /etc/subgid; fi

# Allow myself to use rootless container
if [[ -n "$SUDO_USER" ]]; then
    usermod --add-subuids 165536-231072 --add-subgids 165536-231072 "$SUDO_USER"
fi

# Configure account locking
install -pm644 "$DIR/etc/faillock.conf" /etc/security/faillock.conf

# Sudo settings
install -dm700 /etc/sudoers.d/
install -pm600 -t/etc/sudoers.d "$DIR"/etc/sudoers.d/*

install -pm644 -t/etc/udev/rules.d "$DIR"/etc/udev/*.rules
install -pm644 "$DIR/etc/modprobe-lunaryorn.conf" /etc/modprobe.d/modprobe-lunaryorn.conf
install -pm644 "$DIR/etc/sysctl-lunaryorn.conf" /etc/sysctl.d/90-lunaryorn.conf
install -pm644 "$DIR/etc/lunaryorn-dracut.conf" /etc/dracut.conf.d/50-lunaryorn.conf
# TODO: nssswitch for mdns

# Install or update, and then configure the bootloader
if ! [[ -e /efi/EFI/BOOT/BOOTX64.EFI ]]; then
    bootctl --esp-path=/efi install
else
    bootctl update
fi
install -pm644 "$DIR/etc/loader.conf" /efi/loader/loader.conf

# Global font configuration
for file in 10-hinting-slight 10-sub-pixel-rgb 11-lcdfilter-default; do
    ln -sf /etc/fonts/conf.avail/$file.conf /etc/fonts/conf.d/$file.conf
done

# Apps
flatpaks=(
    org.mozilla.firefox
    com.github.tchx84.Flatseal
    de.bund.ausweisapp.ausweisapp2
    org.gnome.meld
    org.gnome.DejaDup
    org.gnome.Evolution
    org.gnome.Extensions
    org.gnome.Maps
    org.gnome.Weather
    org.gnome.clocks
    org.gnome.dfeet
    org.gnome.seahorse.Application
    org.keepassxc.KeePassXC
    org.libreoffice.LibreOffice
    org.videolan.VLC
    org.signal.Signal
)

flatpak install --or-update --noninteractive "${flatpaks[@]}"
# Force firefox onto wayland
flatpak override --socket=wayland --env=MOZ_ENABLE_WAYLAND=1 org.mozilla.firefox
# Fix https://github.com/flathub/com.skype.Client/issues/126
flatpak override --talk-name=org.freedesktop.ScreenSaver
# Fix https://github.com/flathub/org.gnome.Lollypop/issues/109 (perhaps already fixed)
# flatpak override --filesystem=/tmp org.gnome.Lollypop

if [[ "${HOSTNAME}" == kasterl* ]]; then
    personal_flatpaks=(
        com.skype.Client
        com.valvesoftware.Steam
        org.atheme.audacious
        org.gimp.GIMP
        org.gnome.Lollypop
        org.gnucash.GnuCash
        org.jitsi.jitsi-meet
        org.kde.digikam
        org.stellarium.Stellarium
        re.chiaki.Chiaki
        org.wesnoth.Wesnoth
        com.github.geigi.cozy
    )

    flatpak install --or-update --noninteractive "${personal_flatpaks[@]}"
fi

# Initialize AUR repo
if [[ ! -d /srv/pkgrepo/aur/ ]]; then
    install -m755 -d /srv/pkgrepo
    btrfs subvolume create /srv/pkgrepo/aur
    repo-add /srv/pkgrepo/aur/aur.db.tar.zst
fi

# Allow myself to build AUR packages
if [[ -n "$SUDO_USER" && "$(stat -c '%U' /srv/pkgrepo/aur)" != "$SUDO_USER" ]]; then
    chown -R "$SUDO_USER:$SUDO_USER" /srv/pkgrepo/aur
fi

if ! grep -q '\[aur\]' /etc/pacman.conf; then
    # Add repo to pacman configuration
    cat <<EOF >> /etc/pacman.conf
# aurutils repo
[aur]
SigLevel = Optional TrustAll
Server = file:///srv/pkgrepo/aur/
EOF
    pacman -Sy
fi

# Install aurutils if not yet present
if [[ -n "$SUDO_USER" ]] && ! command -v aur &> /dev/null; then
    sudo -u "$SUDO_USER" bash <<'EOF'
set -xeuo pipefail
BDIR="$(mktemp -d --tmpdir aurutils.XXXXXXXX)"
echo "Building in $BDIR"
cd "$BDIR"
git clone --depth=1 "https://aur.archlinux.org/aurutils.git"
cd aurutils
makepkg --noconfirm --nocheck -rsi
EOF
fi

# Configure aurutils
if [[ ! -e "/etc/aurutils/pacman-aur.conf" ]]; then
    install -pm644 /usr/share/devtools/pacman-extra.conf "/etc/aurutils/pacman-aur.conf"
    cat <<EOF >> "/etc/aurutils/pacman-aur.conf"
# aurutils repo
[aur]
SigLevel = Optional TrustAll
Server = file:///srv/pkgrepo/aur/
EOF
fi

# Remove old dracut hook package
pacman -Rs dracut-hook-uefi || true

aur_packages=(
    # Tiling window manager for Gnome
    gnome-shell-extension-pop-shell
    # Dracut hook to build kernel images for systemd boot
    dracut-hook-uefi-systemd
    # Password manager
    1password
    1password-cli
    # Additional fonts
    otf-vollkorn
    ttf-fira-go
    # Card reader driver for eID
    pcsc-cyberjack
    # Additional tools
    git-gone
    # git-delta
    # dust
    nb
    todotxt
    wcal-git
    # wally
)

aur_optdeps=(
    # nb: Cleanup contents of bookmarks
    readability-cli
)

if [[ -n "$SUDO_USER" ]]; then
    # Build AUR packages and install them
    sudo -u "$SUDO_USER" --preserve-env=AUR_PAGER,PACKAGER aur sync -daur -cRT "${aur_packages[@]}" "${aur_optdeps[@]}"
    pacman --needed -Syu "${aur_packages[@]}"
    pacman --needed -S --asdeps "${aur_optdeps[@]}"
fi

# Cleanup old stuff
packages_to_remove=(
    tela-icon-theme
    plata-theme
)
pacman -Rs "${packages_to_remove[@]}" || true
for package in "${packages_to_remove[@]}"; do
    rm -f /srv/pkgrepo/aur/"$package"-*
done
if [[ -n "$SUDO_USER" ]]; then
    sudo -u "$SUDO_USER" repo-remove /srv/pkgrepo/aur/aur.db.tar.zst "${packages_to_remove[@]}"
fi
