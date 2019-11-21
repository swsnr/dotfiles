#!/bin/bash
# Copyright 2019 Sebastian Wiesner <sebastian@swsnr.de>
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

set -e

[[ "$OSTYPE" == linux-gnu ]] || exit 1;
[[ -f /etc/pacman.conf ]] || exit

echo "Provisioning Arch Linux system"

if [ $EUID != 0 ]; then
    echo "Root required, elevating with sudo $0 $*"
    exec sudo "$0" "$@"
fi

echo "Create AUR repo structure and group"
groupadd --system --force qpkgrepo_aur
install -d /srv/pkgrepo
install -m 2775 -g pkgrepo_aur -d /srv/pkgrepo/aur
setfacl -d -m group:pkgrepo_aur:rwx /srv/pkgrepo/aur
setfacl -m group:pkgrepo_aur:rwx /srv/pkgrepo/aur
if [[ ! -f /srv/pkgrepo/aur/aur.db.tar.xz ]]; then
    echo "Initialize empty package database; ignore the following warnings"
    repo-add /srv/pkgrepo/aur/aur.db.tar.xz
fi

echo "Configure pacman"
install -m644 linux/arch/etc/pacman.conf /etc/pacman.conf
install -m644 linux/arch/etc/pacman-mirrorlist /etc/pacman.d/mirrorlist

echo "Install basic packages"
packages=(
    # System
    base
    # To identify the system
    lsb-release
    # Boot loader
    grub
    # Firmware updates
    fwupd
    # Processor microcode
    intel-ucode
    # Essential editor
    nano
    # Better console font
    terminus-font
    # NTFS support
    ntfs-3g

    # Basic tools
    sudo
    man-db
    # Better ls
    exa
    # Better find
    fd
    # Better grep
    ripgrep
    # Better cat/less
    bat
    # Helpers for pacman
    pacman-contrib
    # Lookup packages by contents
    pkgfile
    # Watch processes
    htop

    # Networking
    bind-tools

    # My shell environment
    fish
    fortune-mod
    cowsay

    # Dev tools
    base-devel
    git
    httpie
    jq
    # Diff/merge tool
    kdiff3
    # Text editor
    code
    shellcheck

    # Python
    python-pylint
    autopep8

    # Java/Scala
    jdk8-openjdk
    openjdk8-doc
    openjdk8-src
    sbt

    # Mono
    mono

    # Containers
    docker
    docker-compose

    # Browser
    firefox
    firefox-i18n-de

    # Gnome shell & basic tools
    gdm
    gnome-shell
    gnome-shell-extensions
    chrome-gnome-shell
    dconf-editor
    gnome-tweaks
    flatpak
    # DBus inspector
    d-feet
    # Gnome software
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-clocks
    gnome-disk-utility
    gnome-documents
    gnome-font-viewer
    gnome-logs
    gnome-screenshot
    gnome-shell-extensions
    gnome-system-monitor
    gnome-todo
    gnome-weather
    # Basic NTP sync
    gnote
    file-roller
    evolution
    evolution-ews
    # Help viewer
    yelp
    # Image viewer & editing
    eog
    gimp
    # Terminal
    tilix
    # Disk space analyzer
    baobab
    # Videos
    totem
    # Preview
    sushi
    # Backup tool
    deja-dup
    # SMB integration for Gnome
    gvfs-smb
    # CLI clipboard access
    wl-clipboard
    # User directories
    xdg-user-dirs

    # Other software
    keepassxc
    # Feed reader
    feedreader

    # Office
    libreoffice-fresh
    libreoffice-fresh-de
    # Hyphenation
    hyphen-de
    hyphen-en
    # Spell checking
    hunspell-de
    hunspell-en_GB
    hunspell-en_US
    # Thesaurus
    mythes-de
    mythes-en

    # Qt5 integration into Qt
    qt5ct
    kvantum-qt5

    # Fonts
    # Metric equivalents for Arial, Times New Roman, etc.
    ttf-liberation
    # …for MS Cambria
    ttf-caladea
    # …for MS Calibri
    ttf-carlito
    # A nice font family for documents
    ttf-fira-code
    ttf-fira-mono
    ttf-fira-sans
    # More nice fonts
    adobe-source-code-pro-fonts
    adobe-source-sans-pro-fonts
    adobe-source-serif-pro-fonts
    # Good UI font for some themes
    ttf-roboto
    # My favourite UI font
    ttf-ubuntu-font-family

    # Dependencies of scripts in my dotfiles
    python-dateutil
    python-keyring

    # LaTex
    texlive-most
)

echo "Install packages"
pacman -Sy --needed --noconfirm "${packages[@]}"

services=(
    # Basic NTP sync
    systemd-timesyncd
    # Hostname resolution
    systemd-resolved
    # Docker daemon
    docker.socket
    # Graphical display
    gdm
    # pkgfile updates
    pkgfile-update.timer
    # Pacman cache cleanup
    paccache.timer
)

echo "Enable systemd services: ${services[*]}"
systemctl enable "${services[@]}"

echo "Redirect resolv.conf to systemd-resolved"
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

echo "Start systemd services: ${services[*]}"
systemctl start "${services[@]}"

echo "Disable pc speaker to silence linux console"
if lsmod | grep -qi pcspkr; then
    rmmod pcspkr
fi
install -m644 linux/etc/nobeep.conf /etc/modprobe.d/nobeep.conf

echo "Configure console font"
install -m644 linux/etc/vconsole.conf /etc/vconsole.conf

echo "Configure system locale"
install -m644 linux/etc/locale.conf /etc/locale.conf

echo "Allow sudo to wheel group members"
install -m700 -d /etc/sudoers.d/
install -m600 linux/etc/sudoers-wheel /etc/sudoers.d/10-wheel

echo "Create locales"
install -m644 linux/etc/locale.gen /etc/locale.gen
locale-gen

echo "Update pkgfile database"
pkgfile --update

echo "Install AUR packages from local repo"
aurpackages=(
    # AUR helpers
    aurutils
    # Nice Gnome theme from Ubuntu
    yaru-gtk-theme
    yaru-icon-theme
    yaru-sound-theme
    # A favourite font of mine
    otf-vollkorn
    # CLI client for 1password
    1password-cli
)

if command -v aur > /dev/null; then
    for package in "${aurpackages[@]}"; do
        if aur repo --list | grep -q "^$package\>"; then
            pacman -Sy --needed --noconfirm "$package"
        else
            echo "AUR package $package not in repo; build with aur build!"
        fi
    done
else
    echo "AUR helper aurutils not installed"
    echo "INSTALL AURUTILS MANUALLY FROM AUR"
fi
