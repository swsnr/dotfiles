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

set -euo pipefail

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
    ansible
    sudo
    efibootmgr
    # System monitoring
    powertop
    iotop
    htop
    # System services
    fwupd
    thermald
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
    # Shell & tools
    man-db
    man-pages
    fish
    git
    exa
    fd
    sd
    ripgrep
    bat
    mdcat
    nnn
    code
    neovim
    rsync
    curl
    p7zip
    zip
    jq
    pandoc
    # Development tools
    meld
    code
    shellcheck
    shfmt
    hub
    github-cli
    ipython
    python-pylint
    autopep8
    rustup
    asciidoctor
    ruby-bundler
    hexyl
    oxipng
    httpie
    # Containers, kubernetes & cloud
    podman
    kubect
    helm
    hcloud
    # Desktop tools
    trash-cli
    wl-clipboard
    xdg-user-dirs
    d-feet
    dconf-editor
    # Desktop services
    pcsclite
    cups
    system-config-printer
    hplip
    bluez
    sane
    # Applications
    deja-dup
    keepassxc
    firefox
    firefox-i18n-de
    signal-desktop
    remmina
    # Multimedia
    gst-plugin-ugly
    gstreamer-vaapi
    vlc
    audacious
    youtube-dl
    avidemux-qt
    mediathekview
    # Office
    libreoffice-fresh
    libreoffice-fresh-de
    hyphen-de
    hyphen-en
    hunspell-de
    hunspell-en_GB
    hunspell-en_US
    mythes-de
    mythes-en
    # Graphics & photos
    digikam
    gimp
    inkscape
    # Personal finances
    gnucash
    # Games
    steam
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
    # Gnome
    gdm
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-clocks
    gnome-disk-utility
    gnome-font-viewer
    gnome-keyring
    gnome-logs
    gnome-maps
    gnome-screenshot
    gnome-shell
    gnome-shell-extensions
    gnome-system-monitor
    gnome-terminal
    gnome-tweaks
    gnome-weather
    seahorse
    file-roller
    yelp
    cheese
    nautilus
    gvfs-afc
    gvfs-goa
    gvfs-google
    gvfs-gphoto2
    gvfs-mtp
    gvfs-nfs
    gvfs-smb
    sushi
    baobab
    evince
    eog
    chrome-gnome-shell
    simple-scan
)

pacman -Syu "${packages[@]}"

optdeps=(
    # nb: rendered notes
    w3m
    # libva: intel drivers
    intel-media-driver
    # ripgrep-all: additional search adapters
    tesseract
    graphicsmagick
    # tesseract: data models
    tesseract-data-deu
    tesseract-data-eng
)

pacman -S --asdeps "${optdeps[@]}"

# Desktop manager
systemctl enable gdm.service
# Thermal control for intel systems
systemctl enable --now thermald.service
# Periodically trim all filesystems
systemctl enable --now fstrim.timer
# Pacman cache cleanup and file database updates
systemctl enable --now paccache.timer
systemctl enable --now pkgfile.timer
# Look for firmware updates
systemctl enable --now fwupd-refresh.timer
# Periodic mirrorlist updates
install -Dpm644 "$DIR/etc/reflector.conf" /etc/xdg/reflector/reflector.conf
systemctl enable --now reflector.timer
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
systemctl enable --now NetworkManager.service
systemctl enable --now avahi-daemon.service
# Printing and other desktop services
systemctl enable --now cups.service
systemctl enable --now bluetooth.service
# Smartcard services for ausweisapp2
systemctl enable --now pcscd.socket

# Sudo settings
install -dm700 /etc/sudoers.d/
install -pm600 -t/etc/sudoers.d \
    "$DIR/etc/sudoers.d/10-defaults" \
    "$DIR/etc/sudoers.d/50-wheel"

install -m644 "$DIR/etc/modprobe-lunaryorn.conf" /etc/modprobe.d/modprobe-lunaryorn.conf
install -m644 "$DIR/etc/sysctl-lunaryorn.conf" /etc/sysctl.d/99-lunaryorn.conf
# TODO: Configure faillock?
# TODO: nssswitch for mdns

# Install or update the bootloader
if ! [[ -e /efi/EFI/BOOT/BOOTX64.EFI ]]; then
    bootctl --esp-path=/efi --boot-path=/boot install
else
    bootctl update
fi

for file in 10-hinting-slight 10-sub-pixel-rgb 11-lcdfilter-default; do
    ln -sf /etc/fonds/conf.avail/$file.conf /etc/fonts/conf.d/$file.conf
done

# TODO: Copy bootloader entries
# TODO: Configure systemd boot

# TODO: Aur packages
# wcal-git
# dust
# otf-vollkorn
# ttf-fira-go
# tela-icon-theme
# plata-theme
# nb
# todotxt
# chiaki
# cozy-audiobooks
# ausweisapp2
# pcsc-cyberjack
# git-gone
# git-delta
# dracut-hook-uefi
