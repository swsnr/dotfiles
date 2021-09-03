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
    exec sudo --preserve-env=AUR_PAGER,PACKAGER,EDITOR "$0" "$@"
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}")"  >/dev/null 2>&1 && pwd)"

# Remove packages I no longer use
to_remove=()
for pkg in "${to_remove[@]}"; do
    pacman --noconfirm -Rs "$pkg" || true
done

packages=(
    # Basic packages & system tools
    base
    dracut # Build initrd & unified EFI images
    linux-firmware
    intel-ucode
    linux
    linux-lts
    lsb-release
    sudo
    zram-generator # swap on compressed RAM
    # File systems
    ntfs-3g
    exfat-utils
    btrfs-progs
    # Hardware tools
    fwupd # Firmware updates
    usbutils
    nvme-cli
    # EFI & secure boot
    efibootmgr # Manage EFI boot menu
    efitools # Low-level EFI tools (just in case, also provides the EFI Keytool binary)
    sbctl # Manage secure boot binaries and sign binaries
    # System monitoring
    powertop
    iotop
    htop
    procs
    lsof
    # Networking
    networkmanager
    # mDNS/DNS-SD, mostly for printers, i.e. CUPS
    # While systemd-resolved handles mDNS hostname lookups it doesn't support DNS-SD,
    # and thus doesn't support CUPS printer discovery, see
    # https://github.com/apple/cups/issues/5452
    avahi
    nss-mdns
    xh # HTTP requests on the command line
    # Arch tools & infrastructure
    pacman-contrib # paccache, checkupdates, pacsearch, and others
    reflector # Weekly mirrorlist updates
    pkgfile # command-not-found for fish
    # Build packages
    base-devel
    namcap
    aurpublish # Publish AUR packages from Git subtrees
    # Terminal, shell & tools
    wezterm
    man-db
    man-pages
    fish
    git
    tig # Curses git interfaces
    neovim
    exa # Better ls (with git support)
    fd # Simpler find
    sd # Simpler sed
    dua-cli # Disk space analyzer
    ripgrep
    bat
    nnn # Command line file manager (also a good pager for aurutils)
    renameutils # qmv is super nice
    rsync
    curl
    p7zip
    zip
    jq
    shellcheck
    shfmt
    # Document processing and rendering
    pandoc
    mdcat
    asciidoctor
    zathura # Lightweight document viewer
    # Development tools
    code
    hub
    github-cli
    rustup
    hexyl # hex viewer
    oxipng # Optimize PNGs for size
    cargo-audit
    cargo-outdated
    cargo-udeps
    cargo-release
    meld # Graphical diff tool (not via flatpak for git diff-tool -g)
    # VMs
    libvirt
    virt-manager
    edk2-ovmf
    # Containers, kubernetes & cloud
    podman
    kubectl
    helm
    # Desktop tools
    wl-clipboard
    dconf-editor
    # Desktop services
    xdg-user-dirs
    xdg-utils
    flatpak
    flatpak-builder # To build flatpaks
    pcsclite # Smartcard daemon, for e-ID
    cups
    hplip
    bluez
    sane
    pipewire-pulse # Pipewire-based pulse-audio, replaces pulseaudio
    # Applications.  Normally I use flatpak, but some core apps work better this
    # way and others just aren't flatpakked yet
    firefox
    firefox-i18n-de
    youtube-dl
    mediathekview # Browse public broadcasting video libraries from Germany
    gpsprune # GPS Track editor
    # Latex
    texlive-most
    # Fonts
    noto-fonts
    noto-fonts-extra
    noto-fonts-cjk
    noto-fonts-emoji
    ttf-liberation
    ttf-caladea
    ttf-carlito
    ttf-cascadia-code
    ttf-fira-code
    ttf-fira-mono
    ttf-fira-sans
    adobe-source-code-pro-fonts
    adobe-source-sans-fonts
    adobe-source-serif-fonts
    ttf-roboto
    ttf-ubuntu-font-family
    ttf-fira-mono
    ttf-fira-sans
    # Gnome
    gdm
    gnome-characters
    gnome-keyring
    gnome-screenshot
    gnome-maps
    gnome-clocks
    gnome-weather
    gnome-shell
    gnome-shell-extensions
    gnome-shell-extension-appindicator
    gnome-system-monitor
    gnome-control-center
    gnome-terminal
    gnome-tweaks
    gnome-software
    xdg-user-dirs-gtk
    evolution
    file-roller
    yelp # Online help system
    nautilus
    gvfs-afc
    gvfs-goa
    gvfs-google
    gvfs-gphoto2
    gvfs-mtp
    gvfs-nfs
    gvfs-smb
    sushi # Previewer for nautilus
    evince # Document viewer
    eog # Image viewer
    simple-scan
    seahorse # Credential manager
)

pacman -Syu --needed "${packages[@]}"

pacman -D --asdeps pipewire-pulse

optdeps=(
    # linux: wireless frequency policies
    crda
    # pipewire: zeroconf support
    pipewire-zeroconf
    # poppler: data files
    poppler-data
    # dracut: --uefi, stripping, and efi signing
    binutils elfutils sbsigntools
    # zathura: PDF support
    zathura-pdf-mupdf
    # libva: intel drivers
    intel-media-driver
    # libvirt: SSH management
    openbsd-netcat
    # libvirt: NAT networking
    dnsmasq ebtables
    # libvirt: DMI info support (whatever that is, but it fixes a warning in libvirtd logs)
    dmidecode
    # libvirt: KVM support
    qemu
    # gnome-shell-extension-appindicator: Gtk3 apps
    libappindicator-gtk3
)

pacman -S --needed --asdeps "${optdeps[@]}"

# Configure btrfs filesystems.
#
# Setup regular scrubbing and enable zstd compression
for mountpoint in / /home /home/"$SUDO_USER"; do
    if findmnt -n -o SOURCE -M "$mountpoint" -v >/dev/null; then
        device="$(findmnt -n -o SOURCE -M "$mountpoint" -v)"
        if [[ "$(lsblk -no FSTYPE "$device")" == "btrfs" ]]; then
            systemctl enable "btrfs-scrub@$(systemd-escape -p "$mountpoint").timer"
            btrfs property set "$mountpoint" compression zstd
        fi
    fi
done

# systemd configuration
install -Dpm644 "$DIR/etc/system-lunaryorn.conf" /etc/systemd/system.conf.d/50-lunaryorn.conf
# Swap on zram
install -Dpm644 "$DIR/etc/zram-generator.conf" /etc/systemd/zram-generator.conf

# Userspace OOM killer from systemd; kills more selectively than the kernel
systemctl enable systemd-oomd.service
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
# Time synchronization
install -Dpm644 "$DIR/etc/timesyncd-lunaryorn.conf" /etc/systemd/timesyncd.conf.d/50-lunaryorn.conf
systemctl enable systemd-timesyncd.service
# Networking
systemctl enable NetworkManager.service
systemctl enable avahi-daemon.service
# Printing and other desktop services
systemctl enable cups.service
systemctl enable bluetooth.service
# Smartcard services for ausweisapp2
systemctl enable pcscd.socket
# Virtualization (mostly for networking, see below; my machines usally run in the user session)
systemctl enable libvirtd.socket

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

# Module & system settings
install -pm644 "$DIR/etc/modprobe-lunaryorn.conf" /etc/modprobe.d/modprobe-lunaryorn.conf
install -pm644 "$DIR/etc/sysctl-lunaryorn.conf" /etc/sysctl.d/90-lunaryorn.conf

# Initrd and early boot
install -pm644 "$DIR/etc/lunaryorn-dracut.conf" /etc/dracut.conf.d/50-lunaryorn.conf
if [[ -f /usr/share/secureboot/keys/db/db.key ]] && [[ -f /usr/share/secureboot/keys/db/db.pem ]]; then
    install -pm644 "$DIR/etc/lunaryorn-dracut-sbctl.conf" /etc/dracut.conf.d/90-lunaryorn-sbctl-signing.conf
else
    rm -f /etc/dracut.conf.d/90-lunaryorn-sbctl-signing.conf
fi
# See /usr/share/factory/etc/nsswitch.conf for the Arch Linux factory defaults.
# We add mdns hostnames (from Avahi) and libvirtd names, and also shuffle things around
# to follow the recommendations in nss-resolve(8) which Arch Linux deliberately doesn't
# do by default, see e.g. https://bugs.archlinux.org/task/57852
NSS_HOSTS=(
    # Resolves containers managed by systemd-machined
    mymachines
    # libvirtd machines (by DHCP announced hostname)
    libvirt
    # Resolves local mDNS hostnames in the .local domain through Avahi, and
    # stops resolving immediately if the .local name isn't found, see
    # https://wiki.archlinux.org/index.php/Avahi#Hostname_resolution
    mdns_minimal '[NOTFOUND=return]'
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

# Allow bridge network access for qemu user sessions
if ip link show virbr0 >& /dev/null; then
    install -dm755 /etc/qemu/

    if ! grep -q 'allow virbr0' /etc/qemu/bridge.conf; then
        echo 'allow virbr0' >> /etc/qemu/bridge.conf
        chmod 644 /etc/qemu/bridge.conf
    fi
fi

# Install or update, and then configure the bootloader
if ! [[ -e /efi/EFI/BOOT/BOOTX64.EFI ]]; then
    bootctl install
else
    bootctl update
fi
install -pm644 "$DIR/etc/loader.conf" /efi/loader/loader.conf

# If we have secureboot tooling in place
if command -v sbctl > /dev/null && [[ -f /usr/share/secureboot/keys/db/db.key ]]; then
    # Generate initial secureboot signatures for systemd-boot
    for file in /efi/EFI/BOOT/BOOTX64.EFI /efi/EFI/systemd/systemd-bootx64.efi; do
        if ! sbctl list-files | grep -q "$file"; then
            sbctl sign -s "$file"
        fi
    done

    # Generate signing firmware updater
    if ! sbctl list-files | grep -q /usr/lib/fwupd/efi/fwupdx64.efi; then
        sbctl sign -s -o /usr/lib/fwupd/efi/fwupdx64.efi.signed /usr/lib/fwupd/efi/fwupdx64.efi
    fi

    # Install keytool
    if [[ ! -f "/efi/loader/entries/keytool.conf" ]]; then
        cat > "/efi/loader/entries/keytool.conf" <<EOF
title EFI Keytool
efi /EFI/KeyTool.efi
EOF
    fi
    if ! sbctl list-files | grep -q /usr/share/efitools/efi/KeyTool.efi; then
        sbctl sign -s -o "/efi/EFI/KeyTool.efi" /usr/share/efitools/efi/KeyTool.efi
    fi

    # Update all secureboot signatures
    sbctl sign-all

    # Dump signing state just to be on the safe side
    sbctl verify
fi

# Global font configuration
for file in 10-hinting-slight 10-sub-pixel-rgb 11-lcdfilter-default; do
    ln -sf /usr/share/fontconfig/conf.avail/$file.conf /etc/fonts/conf.d/$file.conf
done

flatpaks_to_remove=(
    org.gnome.Extensions
    org.gnome.Maps
    org.gnome.Weather
    org.gnome.clocks
    org.gnome.Calculator
    org.gnome.seahorse.Application
    org.gnome.meld
)

flatpak remove --noninteractive "${flatpaks_to_remove[@]}"

# Apps
flatpaks=(
    com.github.tchx84.Flatseal # Manage flatpak permissions
    io.github.Qalculate # Scientific calculator
    io.github.seadve.Kooha # Screen recorder
    org.signal.Signal # Messenger
    org.gimp.GIMP # Image editor
    org.inkscape.Inkscape # SVG editor
    org.videolan.VLC # Videos
    de.bund.ausweisapp.ausweisapp2 # e-ID
    org.libreoffice.LibreOffice # Office
    org.standardnotes.standardnotes # Personal notes
    org.stellarium.Stellarium # Stars and the sky
    io.freetubeapp.FreeTube # A privacy focused youtube client
    com.gitlab.newsflash # News reader und miniflux client
)

flatpak install --or-update --noninteractive "${flatpaks[@]}"

# Fix https://github.com/flathub/com.skype.Client/issues/126
flatpak override --talk-name=org.freedesktop.ScreenSaver
# Fix https://github.com/flathub/org.gnome.Lollypop/issues/109 (perhaps already fixed)
# flatpak override --filesystem=/tmp org.gnome.Lollypop

if [[ "${HOSTNAME}" == kasterl* ]]; then
    personal_flatpaks=(
        org.gnome.DejaDup # Backups of personal data
        com.skype.Client # Sadly necessary
        org.jitsi.jitsi-meet # Secure video chats
        org.atheme.audacious # Audio player
        org.gnome.Lollypop # Music manager
        com.github.geigi.cozy # Audio player
        org.gnucash.GnuCash # Personal finances
        org.kde.digikam # Photo collection
        re.chiaki.Chiaki # PSN remote play client
        com.valvesoftware.Steam # Gaming
        org.wesnoth.Wesnoth
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
    cat <<EOF >>/etc/pacman.conf
# aurutils repo
[aur]
SigLevel = Optional TrustAll
Server = file:///srv/pkgrepo/aur/
EOF
    pacman -Sy
fi

# Install aurutils if not yet present
if [[ -n "$SUDO_USER" ]] && ! command -v aur &>/dev/null; then
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
    cat <<EOF >>"/etc/aurutils/pacman-aur.conf"
# aurutils repo
[aur]
SigLevel = Optional TrustAll
Server = file:///srv/pkgrepo/aur/
EOF
fi

aur_packages=(
    # AUR helper
    aurutils
    # Splash screen at boot
    plymouth
    # Gtk themes
    yaru-gtk-theme
    yaru-icon-theme
    # Gnome extensions
    gnome-shell-extension-nasa-apod
    # Gnome tools
    gnome-search-providers-jetbrains
    gnome-search-providers-vscode
    # Dracut hook to build kernel images for systemd boot
    dracut-hook-uefi
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
    readability-cli # Remove cruft from HTML, for better content capture in nb
    # git-delta
    wcal-git
    coursier-native
    # Missing dependencies for latexindent
    # See <https://bugs.archlinux.org/task/60210>
    texlive-latexindent-meta
    # Keyboard flashing tool
    zsa-wally
    zsa-wally-cli
)

aur_optdeps=(
    # aur-utils: chroot support
    devtools
    # plymouth: truetype fonts
    ttf-dejavu cantarell-fonts
)

if [[ -n "$SUDO_USER" ]]; then
    # Build AUR packages and install them
    sudo -u "$SUDO_USER" --preserve-env=AUR_PAGER,PACKAGER,EDITOR aur sync -daur -cRT "${aur_packages[@]}" "${aur_optdeps[@]}"
    pacman --needed -Syu "${aur_packages[@]}"
    pacman --needed -S --asdeps "${aur_optdeps[@]}"

    remove_from_repo=()
    for pkg in "${remove_from_repo[@]}"; do
        rm -f "/srv/pkgrepo/aur/${pkg}-"*.pkg.tar.*
    done
    sudo -u "$SUDO_USER" repo-remove /srv/pkgrepo/aur/aur.db.tar.zst "${remove_from_repo[@]}"
fi

if command -v plymouth-set-default-theme > /dev/null; then
    plymouth-set-default-theme bgrt
fi
