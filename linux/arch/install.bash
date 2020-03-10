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

[[ $OSTYPE == linux-gnu ]] || exit 1
[[ -f /etc/pacman.conf ]] || exit

function h1() {
    local colour
    case "$1" in
    --warn)
        colour='31;1'
        shift 1
        ;;
    --ignore)
        colour='37'
        shift 1
        ;;
    *)
        colour='32'
        ;;
    esac

    local words
    printf -v words '%s ' "$@"

    printf '\033[%sm%s\033[0m\n' "$colour" "$words"
}

h1 "Provisioning Arch Linux system"

if [[ $EUID != 0 ]]; then
    h1 --warn "Root required, elevating with sudo $0 $*"
    exec sudo "$0" "$@"
fi

if [[ $1 == "--all" ]]; then
    FAST="false"
else
    FAST="true"
fi

function do-all() {
    [[ $FAST == 'false' ]] && return 0 || return 1
}

h1 "Disable pc speaker to silence linux console"
if lsmod | grep -qi pcspkr; then
    rmmod pcspkr
fi
install -m644 linux/etc/nobeep.conf /etc/modprobe.d/nobeep.conf

h1 "Enable intel fastboot"
install -m644 linux/etc/i915.conf /etc/modprobe.d/i915.conf

h1 "Configure console font"
install -m644 linux/etc/vconsole.conf /etc/vconsole.conf

h1 "Configure system locale"
install -m644 linux/etc/locale.conf /etc/locale.conf

h1 "Configure system settings"
install -m644 linux/arch/etc/sysctl-laptop.conf /etc/sysctl.d/laptop.conf

h1 "Configure module settings"
install -m644 linux/arch/etc/modprobe-powersave.conf /etc/modprobe.d/powersave.conf

h1 "Allow sudo to wheel group members"
install -m700 -d /etc/sudoers.d/
install -m600 linux/arch/etc/sudoers-wheel /etc/sudoers.d/10-wheel

if do-all; then
    h1 "Create locales"
    install -m644 linux/etc/locale.gen /etc/locale.gen
    locale-gen
else
    h1 --ignore "Create locales (SKIPPED)"
fi

h1 "Create AUR repo structure and group"
groupadd --system --force pkgrepo_aur
install -d /srv/pkgrepo
install -m 2775 -g pkgrepo_aur -d /srv/pkgrepo/aur
setfacl -d -m group:pkgrepo_aur:rwx /srv/pkgrepo/aur
setfacl -m group:pkgrepo_aur:rwx /srv/pkgrepo/aur
if [[ ! -f /srv/pkgrepo/aur/aur.db.tar.xz ]]; then
    h1 "Initialize empty package database; ignore the following warnings"
    repo-add /srv/pkgrepo/aur/aur.db.tar.xz
fi

h1 "Configure pacman"
install -m644 linux/arch/etc/pacman.conf /etc/pacman.conf
install -m644 linux/arch/etc/pacman-mirrorlist /etc/pacman.d/mirrorlist

packages=(
    # System
    base
    # To identify the system
    lsb-release
    # Firmware updates
    fwupd
    # Processor microcode
    intel-ucode
    # Essential editor
    nano
    # Better console font
    terminus-font
    # Additional filesystems
    ntfs-3g
    exfat-utils
    # EFI boot loaders
    efibootmgr

    # Basic tools
    sudo
    # Manpages…
    man-db
    # …and simpler manpages
    tldr
    # Better ls
    exa
    # and dircolors for ls
    vivid
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
    # Copying
    rsync

    # Networking
    networkmanager
    bind-tools
    # mDNS
    avahi
    nss-mdns
    # Better WiFi networking (no more wpa_supplicant)
    iwd

    # My shell environment
    fish
    fortune-mod
    cowsay

    # Dev tools
    base-devel
    git
    httpie
    jq
    shfmt
    # Diff/merge tool
    meld
    # Text editor
    code
    # Shell linter
    shellcheck
    # Site generator
    hugo

    # Python
    python-pylint
    autopep8

    # Java/Scala
    jdk8-openjdk
    openjdk8-doc
    openjdk8-src
    sbt

    # Misc
    rustup

    # Gnome shell & basic tools
    gdm
    gnome-shell
    gnome-shell-extensions
    dconf-editor
    gnome-tweaks
    # User directories
    xdg-user-dirs
    # CLI clipboard access
    wl-clipboard

    # DBus inspector
    d-feet

    # Gnome software
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-clocks
    gnome-disk-utility
    gnome-font-viewer
    gnome-logs
    gnome-screenshot
    gnome-shell-extensions
    gnome-system-monitor
    gnome-weather
    file-roller
    yelp

    # Backup tool
    deja-dup

    # File management
    nautilus
    # Previewing
    sushi
    # Disk space analyzer
    baobab
    # File protocols
    gvfs-smb
    gvfs-mtp

    # Browser
    firefox
    firefox-i18n-de
    feedreader
    # Communication
    signal-desktop

    # Images
    eog
    gimp
    inkscape
    graphviz

    # Terminal
    tilix

    # Multimedia
    ponymix
    totem
    vlc
    rhythmbox
    youtube-dl

    # Documents
    gnome-documents
    evince
    simple-scan

    # Desktop wiki, note taking, TODO lists
    zim

    # i3 environment (w/ i3-gnome from AUR)
    # i3-wm
    # i3blocks
    # # Display configuration
    # autorandr
    # # Screen locking
    # xss-lock
    # i3lock-color
    # # Desktop env: launcher, XDG autostart, notifications, and applets
    # rofi
    # dex
    # dunst
    # network-manager-applet
    # pasystray
    # udiskie
    # # Apps for i3
    # xarchiver
    # nomacs
    # flameshot
    # zathura

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

    # Gtk theme
    arc-gtk-theme

    # Qt5 integration into Qt
    qt5ct
    kvantum-qt5

    # Printing
    cups
    cups-pdf

    # Fonts
    # Basic sets of fonts for good language support
    noto-fonts
    noto-fonts-cjk
    noto-fonts-extra
    noto-fonts-emoji
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

h1 "Install packages"
pacman -Sy --needed --noconfirm "${packages[@]}"

optdeps=(
    # avahi: avahi-discover GUI tool
    python-dbus
    # zathura: PDF support
    zathura-pdf-mupdf
    # zim: source code viewing and spell checking
    gtksourceview3
    gtkspell3
)

h1 "Install optional dependencies of packages"
pacman -Sy --needed --noconfirm --asdeps "${optdeps[@]}"

h1 "Configure NSS"
install -m644 linux/arch/etc/nsswitch.conf /etc/nsswitch.conf

services=(
    # Periodically trim file systems
    fstrim.timer
    # WiFi and network management
    iwd
    NetworkManager
    # Basic NTP sync
    systemd-timesyncd
    # Hostname resolution
    systemd-resolved
    # mDNS support
    avahi-daemon.service
    # Printing system (on demand)
    org.cups.cupsd.socket
    # Graphical display
    gdm
    # pkgfile updates
    pkgfile-update.timer
    # Pacman cache cleanup
    paccache.timer
)

h1 "Enable systemd services"
systemctl enable "${services[@]}"

h1 "Make NetworkManager use iwd for Wifi management"
install -m644 linux/arch/etc/networkmanager-wifi-backend-iwd.conf \
    /etc/NetworkManager/conf.d/wifi-backend.conf

h1 "Configure systemd-resolved"
install -m644 linux/arch/etc/systemd-resolved.conf /etc/systemd/resolved.conf

h1 "Redirect resolv.conf to systemd-resolved"
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

h1 "Start systemd services"
systemctl start "${services[@]}"

if do-all; then
    h1 "Update pkgfile database"
    pkgfile --update
else
    h1 --ignore "Update pkgfile database (SKIPPED)"
fi

h1 "Install AUR packages from local repo"
aurpackages=(
    # AUR helpers
    aurutils
    # Shell extension for system tray icons
    gnome-shell-extension-appindicator
    # Lovely icon theme :)
    numix-circle-icon-theme-git
    numix-cursor-theme

    # i3 session for GDM, also with optional gnome support
    i3-gnome

    # A favourite font of mine
    otf-vollkorn

    # Scala REPL
    ammonite

    # TLA+
    tla-toolbox

    # PS4 remote client
    chiaki

    # Boot message
    mkinitcpio-bootmsg

    # Personal tools
    mdcat
    git-gone
)

if ! pacman -Sy --needed --noconfirm "${aurpackages[@]}"; then
    h1 --warn "AUR packages failed to install"

    if command -v aur >/dev/null; then
        h1 "Build the following AUR packages:"
        for package in "${aurpackages[@]}"; do
            if ! aur repo --list | grep -q "^$package\>"; then
                echo "  * ${package}"
            fi
        done
    else
        h1 'Build and install aurutils first'
    fi
fi
