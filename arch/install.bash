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
    # Development tools
    # meld
    code
    hub
    github-cli
    rustup
    hexyl
    oxipng
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
    flatpak
    pcsclite
    cups
    system-config-printer
    hplip
    bluez
    sane
    pipewire-pulse
    # Applications
    # firefox
    # firefox-i18n-de
    # Multimedia
    # gst-plugin-ugly
    # gstreamer-vaapi
    # vlc
    # audacious
    # youtube-dl
    # avidemux-qt
    # mediathekview
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
    chrome-gnome-shell
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
    #w3m
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
# Thermal control for intel systems
systemctl enable thermald.service
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

# Sudo settings
install -dm700 /etc/sudoers.d/
install -pm600 -t/etc/sudoers.d \
    "$DIR/etc/sudoers.d/10-defaults" \
    "$DIR/etc/sudoers.d/50-wheel"

install -m644 "$DIR/etc/modprobe-lunaryorn.conf" /etc/modprobe.d/modprobe-lunaryorn.conf
install -m644 "$DIR/etc/sysctl-lunaryorn.conf" /etc/sysctl.d/99-lunaryorn.conf
# TODO: Configure faillock?
# TODO: nssswitch for mdns

# Configure dracut
install -m644 "$DIR/etc/lunaryorn-dracut.conf" /etc/dracut.conf.d/lunaryorn.conf

# Install or update the bootloader
if ! [[ -e /efi/EFI/BOOT/BOOTX64.EFI ]]; then
    bootctl --esp-path=/efi install
else
    bootctl update
fi
# Configure the loader menu
install -m644 "$DIR/etc/loader.conf" /efi/loader/loader.conf

# Global font configuration
for file in 10-hinting-slight 10-sub-pixel-rgb 11-lcdfilter-default; do
    ln -sf /etc/fonts/conf.avail/$file.conf /etc/fonts/conf.d/$file.conf
done

# Apps
flatpaks=(
    com.github.tchx84.Flatseal
    de.bund.ausweisapp.ausweisapp2
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
        org.signal.Signal
        re.chiaki.Chiaki
        org.wesnoth.Wesnoth
    )

    flatpak install --or-update --noninteractive "${personal_flatpaks[@]}"
fi

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
