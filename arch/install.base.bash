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

# Install my basic Arch system

set -xeuo pipefail

if [[ $EUID != 0 ]]; then
    echo 'Elevating privileges'
    exec sudo --preserve-env=AUR_PAGER,PACKAGER,EDITOR "$0" "$@"
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}")"  >/dev/null 2>&1 && pwd)"

PRODUCT_NAME="$(< /sys/class/dmi/id/product_name)"

# Remove packages I no longer use
to_remove=(
    # Remove linux-lts; I'm now using the standard kernel
    linux-lts
    # I don't really use Github so often anymore
    hub
    github-cli
)
for pkg in "${to_remove[@]}"; do
    pacman --noconfirm -Rs "$pkg" || true
done

# Configure pacman to update systemd-boot after systemd updates
# Doesn't play well with sbctl currently, see https://github.com/Foxboron/sbctl/issues/119
# install -Dpm644 "$DIR/etc/pacman-zz-systemd-boot.hook" /etc/pacman.d/hooks/zz-systemd-boot.hook

packages=(
    # Basic packages & system tools
    base
    # FIXME: We currently use dracut git for some crucial MRs which haven't been released yet:
    # - <https://github.com/dracutdevs/dracut/pull/1526>: tpm2-tss module dependencies have a typo
    # - <https://github.com/dracutdevs/dracut/pull/1658>: TPM2 user wasn't created because sysusers didn't run
    # When dracut 56 gets to arch go back to packaged dracut
    #dracut # Build initrd & unified EFI images
    linux-firmware
    intel-ucode
    linux
    lsb-release
    sudo
    zram-generator # swap on compressed RAM, mostly to support systemd-oomd
    sbctl # Manage secure boot binaries and sign binaries
    # File systems
    ntfs-3g
    exfat-utils
    btrfs-progs
    # Hardware tools
    fwupd # Firmware updates
    usbutils
    nvme-cli
    # Keyboard flashing tool
    zsa-wally
    zsa-wally-cli
    # System monitoring
    iotop
    htop
    procs
    lsof
    # Power management
    powertop
    power-profiles-daemon
    # Networking
    networkmanager
    # DNS-SD, mostly for printers, i.e. CUPS. Service discovery is handled by Avahi,
    # name resolution by systemd-resolved.
    avahi
    xh # HTTP requests on the command line
    step-cli # Create CA & leaf certificates
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
    git-filter-repo
    tig # Curses git interfaces
    neovim
    exa # Better ls (with git support)
    fd # Simpler find
    sd # Simpler sed
    dua-cli # Disk space analyzer
    ripgrep
    ripgrep-all
    bat
    nnn # Command line file manager (also a good pager for aurutils)
    renameutils # qmv is super nice
    rsync
    rclone # rsync for clouds
    restic # Backups
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
    # Spellchecking
    hunspell
    hunspell-de
    hunspell-en_gb
    hunspell-en_us
    # Development tools
    rustup
    hexyl # hex viewer
    oxipng # Optimize PNGs for size
    cargo-audit
    cargo-outdated
    cargo-udeps
    cargo-release
    meld # Graphical diff tool (not via flatpak for git diff-tool -g)
    # Desktop tools
    wl-clipboard
    dconf-editor
    # Desktop services
    xdg-user-dirs
    xdg-utils
    flatpak
    pcsclite # Smartcard daemon, for e-ID
    cups
    hplip
    bluez
    sane
    pipewire-pulse # Pipewire-based pulse-audio, replaces pulseaudio
    wireplumber # Recommended pipewire session & policy manager
    # Applications.  Normally I use flatpak, but some core apps work better this
    # way and others just aren't flatpakked yet
    firefox
    firefox-i18n-de
    youtube-dl
    mediathekview # Browse public broadcasting video libraries from Germany
    gpsprune # GPS Track editor
    zim # Notes, Journal & Zettelkasten (works better as package)
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
    gnome-backgrounds
    gnome-themes-extra # For adwaita-dark
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
    # Multimedia for gnome
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
)

pacman -Syu --needed "${packages[@]}"

# Mark pipewire as optdeps to cleanly uninstall them once they are no longer needed.
pacman -D --asdeps pipewire-pulse wireplumber

optdeps=(
    # linux: wireless frequency policies
    crda
    # pipewire: zeroconf support
    pipewire-zeroconf
    # poppler: data files
    poppler-data
    # dracut: --uefi, stripping, and efi signing
    binutils elfutils sbsigntools
    # dracut: tpm2-tss
    tpm2-tools
    # zathura: PDF support
    zathura-pdf-mupdf
    # libva: intel drivers
    intel-media-driver
    # gnome-shell-extension-appindicator: Gtk3 apps
    libappindicator-gtk3
    # aurutils: chroot support
    devtools
    # zim: spell checking
    gtkspell3
)

pacman -S --needed --asdeps "${optdeps[@]}"
pacman -D --asdeps "${optdeps[@]}"

# Setup regular scrubbing on btrfs
systemctl enable "btrfs-scrub@$(systemd-escape -p /).timer"
if [[ -n "${SUDO_USER:-}" ]]; then
    systemctl enable "btrfs-scrub@$(systemd-escape -p "/home/${SUDO_USER}").timer"
fi

# systemd configuration
install -Dpm644 "$DIR/etc/systemd/system-lunaryorn.conf" /etc/systemd/system.conf.d/50-lunaryorn.conf
# Swap on zram
install -Dpm644 "$DIR/etc/systemd/zram-generator.conf" /etc/systemd/zram-generator.conf

# Update boot loader automatically
systemctl enable systemd-boot-update.service
# homed for user management and home areas
systemctl enable systemd-homed.service
# Userspace OOM killer from systemd; kills more selectively than the kernel
install -Dpm644 "$DIR/etc/systemd/oomd-lunaryorn.conf" /etc/systemd/oomd.conf.d/oomd-lunaryorn.conf
install -Dpm644 "$DIR/etc/systemd/root-slice-oomd-lunaryorn.conf" /etc/systemd/system/-.slice.d/50-oomd-lunaryorn.conf
install -Dpm644 "$DIR/etc/systemd/user-service-oomd-lunaryorn.conf" /etc/systemd/system/user@.service.d/50-oomd-lunaryorn.conf
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
# Power management
systemctl enable power-profiles-daemon.service
# DNS resolver daemon (w/ caching)
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
install -Dpm644 "$DIR/etc/systemd/resolved-lunaryorn.conf" /etc/systemd/resolved.conf.d/50-lunaryorn.conf
systemctl enable systemd-resolved.service
# Networking
install -Dpm644 "$DIR/etc/networkmanager-mdns.conf" /etc/NetworkManager/conf.d/50-mdns.conf
systemctl enable NetworkManager.service
systemctl enable avahi-daemon.service
# Time synchronization
install -Dpm644 "$DIR/etc/systemd/timesyncd-lunaryorn.conf" /etc/systemd/timesyncd.conf.d/50-lunaryorn.conf
systemctl enable systemd-timesyncd.service
# Printing and other desktop services
systemctl enable cups.service
systemctl enable bluetooth.service
# Smartcard services for ausweisapp2
systemctl enable pcscd.socket

if [[ ! -f /etc/subuid ]]; then touch /etc/subuid; fi
if [[ ! -f /etc/subgid ]]; then touch /etc/subgid; fi

# Allow myself to use rootless container
if [[ -n "${SUDO_USER:-}" ]]; then
    usermod --add-subuids 165536-231072 --add-subgids 165536-231072 "$SUDO_USER"
fi

# Configure account locking
install -pm644 "$DIR/etc/faillock.conf" /etc/security/faillock.conf

# Sudo settings
install -dm750 /etc/sudoers.d/
install -pm600 -t/etc/sudoers.d "$DIR"/etc/sudoers.d/*

# System settings and module parameters
install -pm644 "$DIR/etc/sysctl-lunaryorn.conf" /etc/sysctl.d/90-lunaryorn.conf
install -pm644 "$DIR/etc/modprobe-lunaryorn.conf" /etc/modprobe.d/modprobe-lunaryorn.conf
if [[ $PRODUCT_NAME == "TUXEDO InfinityBook 14 v2" ]]; then
    install -pm644 "$DIR/etc/modprobe-lunaryorn-tuxedo.conf" /etc/modprobe.d/modprobe-lunaryorn-tuxedo.conf
else
    rm -f /etc/modprobe.d/modprobe-lunaryorn-tuxedo.conf
fi

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

# If we have secureboot tooling in place
if command -v sbctl > /dev/null && [[ -f /usr/share/secureboot/keys/db/db.key ]]; then
    # Remove legacy signing for bootloader.
    for file in /efi/EFI/BOOT/BOOTX64.EFI /efi/EFI/systemd/systemd-bootx64.efi; do
        sbctl remove-file "$file" || true
    done

    # Generate signed bootloader image
    if ! sbctl list-files | grep -q /usr/lib/systemd/boot/efi/systemd-bootx64.efi; then
        sbctl sign -s -o /usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed /usr/lib/systemd/boot/efi/systemd-bootx64.efi
        bootctl update --graceful
    fi

    # Generate signed firmware updater
    if ! sbctl list-files | grep -q /usr/lib/fwupd/efi/fwupdx64.efi; then
        sbctl sign -s -o /usr/lib/fwupd/efi/fwupdx64.efi.signed /usr/lib/fwupd/efi/fwupdx64.efi
    fi

    # Update all secureboot signatures
    sbctl sign-all

    # Dump signing state just to be on the safe side
    sbctl verify
fi

# Install or update, and then configure the bootloader.
# Do this AFTER signing the boot loader with sbctl, see above, to make sure we
# install the signed loader.
if ! [[ -e /efi/EFI/BOOT/BOOTX64.EFI ]]; then
    bootctl install
else
    bootctl update --graceful
fi
install -pm644 "$DIR/etc/loader.conf" /efi/loader/loader.conf

# Locale settings
localectl set-locale de_DE.UTF-8
# --no-convert stops localectl from trying to apply the text console layout to
# X11/Wayland and vice versa
localectl set-keymap --no-convert us
localectl set-x11-keymap --no-convert us,de pc105 mac,

# Remove EFI keytool (recent sbctl versions can enroll keys flawlessly so we no longer need keytool)
if [[ -f "/efi/loader/entries/keytool.conf" ]]; then
    sbctl remove-file /usr/share/efitools/efi/KeyTool.efi
    rm /efi/loader/entries/keytool.conf
fi

# Global font configuration
for file in 10-hinting-slight 10-sub-pixel-rgb 11-lcdfilter-default; do
    ln -sf /usr/share/fontconfig/conf.avail/$file.conf /etc/fonts/conf.d/$file.conf
done

# GDM dconf profile, for global GDM configuration, see
# https://help.gnome.org/admin/system-admin-guide/stable/login-banner.html.en
install -Dpm644 "$DIR/etc/gdm-profile" /etc/dconf/profile/gdm

# Apps to try:
# - https://github.com/sonnyp/tangram

# Common applications
flatpaks=(
    com.github.tchx84.Flatseal # Manage flatpak permissions
    org.gnome.World.Secrets # Keepass database access
    io.github.Qalculate # Scientific calculator
    io.github.seadve.Kooha # Screen recorder
    org.signal.Signal # Messenger
    org.gimp.GIMP # Image editor
    org.inkscape.Inkscape # SVG editor
    org.videolan.VLC # Videos
    org.libreoffice.LibreOffice # Office
    org.standardnotes.standardnotes # Personal notes
    org.stellarium.Stellarium # Stars and the sky
    io.freetubeapp.FreeTube # A privacy focused youtube client
    com.gitlab.newsflash # News reader und miniflux client
    org.gnome.Lollypop # Music manager
    org.gaphor.Gaphor # UML editor
    com.github.xournalpp.xournalpp # Handwritten note taking (for Wacom tablet)
)
flatpak install --system --or-update --noninteractive "${flatpaks[@]}"

# Initialize AUR repo
if [[ ! -d /srv/pkgrepo/aur/ ]]; then
    install -m755 -d /srv/pkgrepo
    btrfs subvolume create /srv/pkgrepo/aur
    repo-add /srv/pkgrepo/aur/aur.db.tar.zst
fi

# Allow myself to build AUR packages
if [[ -n "${SUDO_USER:-}" && "$(stat -c '%U' /srv/pkgrepo/aur)" != "$SUDO_USER" ]]; then
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
if [[ -n "${SUDO_USER:-}" ]] && ! command -v aur &>/dev/null; then
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
    install -Dpm644 /usr/share/devtools/pacman-extra.conf "/etc/aurutils/pacman-aur.conf"
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
    # initramfs
    dracut-git
    # Editor
    vscodium-bin
    # Splash screen at boot
    plymouth
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
    # git-delta
    wcal-git
    coursier-native
    # Missing dependencies for latexindent
    # See <https://bugs.archlinux.org/task/60210>
    texlive-latexindent-meta
)

aur_optdeps=(
    # plymouth: truetype fonts
    ttf-dejavu cantarell-fonts
)

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

    remove_from_repo=()
    if [[ ${#remove_from_repo[@]} -gt 0 ]]; then
        for pkg in "${remove_from_repo[@]}"; do
            rm -f "/srv/pkgrepo/aur/${pkg}-"*.pkg.tar.*
        done
        sudo -u "$SUDO_USER" repo-remove /srv/pkgrepo/aur/aur.db.tar.zst "${remove_from_repo[@]}" || true
    fi
fi

# Set plymouth theme
if command -v plymouth-set-default-theme > /dev/null; then
    plymouth-set-default-theme bgrt
fi
