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

PRESERVE_ENV=AUR_PAGER,PACKAGER,EDITOR

if [[ $EUID != 0 ]]; then
    echo 'Elevating privileges'
    exec sudo --preserve-env="${PRESERVE_ENV}" "$0" "$@"
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}")"  >/dev/null 2>&1 && pwd)"

PRODUCT_NAME="$(< /sys/class/dmi/id/product_name)"

PACKAGE_SIGNING_KEY="B8ADA38BC94C48C4E7AABE4F7548C2CC396B57FC"

# Configure pacman
install -pm644 "$DIR/etc/pacman/pacman.conf" /etc/pacman.conf
# Remove outdated config files
rm -f /etc/pacman.d/conf.d/{60-aurutils-repository.conf,55-multilib-repository.conf,51-multilib-repository.conf}
# Configure core pacman options and official repositories
install -pm644 -Dt /etc/pacman.d/conf.d \
    "$DIR/etc/pacman/00-global-options.conf" \
    "$DIR/etc/pacman/50-core-repositories.conf"

# Update pacman keyring with additional keys
pacman-key -a "$DIR/etc/pacman/keys/personal.asc"
pacman-key --lsign-key B8ADA38BC94C48C4E7AABE4F7548C2CC396B57FC

# Mark packages I no longer use as dependencies
to_remove=(
    # /etc/os-release is much better
    lsb-release
    # I use Gnome tools directly; the XDG stuff should come as a dependencies
    # if required.  Also many of these tools are poorly maintainted
    xdg-utils
    xdg-user-dirs
    xdg-user-dirs-gtk
    # These are required as dependency if needed
    xdg-desktop-portal-gnome
    xdg-desktop-portal
    # Things I no longer use
    tea
    gnome-remote-desktop
    gnome-screenshot
    gnome-themes-extra
    # Things moved to flatpak
    chiaki
    ausweisapp2
    cozy-audiobooks
    vlc
    inkscape
    gimp
    libreoffice-fresh-de
    libreoffice-fresh
    xournalpp
    d-feet
    picard
    digikam
    signal-desktop
    lollypop
    zim
    gnucash
    gnucash-docs
    steam
)
for pkg in "${to_remove[@]}"; do
    pacman --noconfirm -D --asdeps "$pkg" || true
done

# Automatically remove unneeded dependencies; this automatically uninstalls
# unneeded packages
pacman -Qtdq | pacman --noconfirm -Rs - || true

packages=(
    # Basic packages & system tools
    base
    dracut # Build initrd & unified EFI images
    linux-firmware
    intel-ucode
    linux
    linux-zen
    sudo
    zram-generator # swap on compressed RAM, mostly to support systemd-oomd
    sbctl # Manage secure boot binaries and sign binaries
    # File systems
    ntfs-3g
    exfatprogs
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
    firewalld
    # DNS-SD, mostly for printers, i.e. CUPS. Service discovery is handled by Avahi,
    # name resolution by systemd-resolved.
    avahi
    xh # HTTP requests on the command line
    step-cli # Create CA & leaf certificates
    # Arch tools & infrastructure
    asp # Obtain PKGBUILDs for ABS
    pacman-contrib # paccache, checkupdates, pacsearch, and others
    reflector # Weekly mirrorlist updates
    pkgfile # command-not-found for fish
    kernel-modules-hook # Keep kernel modules on kernel updates
    # Build packages
    base-devel
    namcap
    # Terminal, shell & tools
    wezterm
    man-db
    man-pages
    fish
    code
    neovim
    exa # Better ls (with git support)
    vivid # Creates themes for dircolors
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
    # Git and related tools
    git
    git-filter-repo
    tig # Curses git interfaces
    # Rust tooling
    rustup
    cargo-audit
    cargo-outdated
    cargo-udeps
    cargo-release
    cargo-deny
    # Bash tools
    shellcheck
    shfmt
    # Other development tools
    hexyl # hex viewer
    oxipng # Optimize PNGs for size
    jq # Process JSON on command line
    # Desktop tools
    wl-clipboard
    dconf-editor
    # Desktop services
    flatpak
    pcsclite # Smartcard daemon, for e-ID
    cups
    hplip
    bluez
    sane
    pipewire-pulse # Pipewire-based pulse-audio, replaces pulseaudio
    wireplumber # Recommended pipewire session & policy manager
    firefox # Browser
    firefox-i18n-de
    yt-dlp # youtube-dl with extra features
    kdiff3 # Diff & merge tool
    # Latex
    texlive-most
    # Fonts & themes
    # Fallback font with huge coverage and colored emojis
    noto-fonts
    noto-fonts-extra
    noto-fonts-cjk
    noto-fonts-emoji
    # Microsoft compatibility fonts
    ttf-liberation
    ttf-caladea
    ttf-carlito
    ttf-cascadia-code
    # My user interface fonts
    ttf-ubuntu-font-family
    ttf-jetbrains-mono
    # Gnome
    gdm
    gnome-characters
    gnome-keyring
    gnome-maps
    gnome-clocks
    gnome-weather
    gnome-shell
    gnome-shell-extensions
    gnome-shell-extension-appindicator
    gnome-system-monitor
    gnome-control-center
    gnome-tweaks
    gnome-backgrounds
    evolution
    file-roller
    yelp # Online help system
    nautilus
    python-nautilus
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
    baobab # Disk space analyser
    # Multimedia for gnome
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
)

optdeps=(
    # pipewire
    pipewire-pulse wireplumber
    # linux: wireless frequency policies (provided as crda)
    wireless-regdb
    # pipewire: zeroconf support
    pipewire-zeroconf
    # poppler: data files
    poppler-data
    # dracut:
    binutils # --uefi
    elfutils # stripping
    sbsigntools # efi signing
    tpm2-tools # tpm2-tss
    # zathura: PDF support
    zathura-pdf-mupdf
    # libva: intel drivers
    intel-media-driver
    # gnome-shell-extension-appindicator: GTK3 apps
    libappindicator-gtk3
    # aurutils: chroot support
    devtools
)

case "$HOSTNAME" in
    *kastl*)
        packages+=(
            mediathekview # Browse public broadcasting video libraries from Germany
            gpsprune # GPS Track editor
        )
        ;;
    *RB*)
        packages+=(
            virtualbox-host-modules-arch
            virtualbox-guest-iso
            virtualbox
            # .NET development
            dotnet-sdk
            # Containers, kubernetes & cloud
            podman
            kubectl
            helm
            # Large file storage
            git-lfs
            # VPN
            networkmanager-vpnc
            networkmanager-openconnect
            # Networking and debugging tools
            lftp # Powerful FTP client
            websocat # Debug websockets on the CLI
            lnav # Log file analyzer
            # Additional applications
            filezilla # FTP client
            keepassxc # Keepass
            evolution-ews # Exchange for evolution
            gnome-calendar # Simple calendar view and notifications
            remmina # Remote desktop
            mattermost-desktop # Chat
        )

        optdeps+=(
            # virtualbox: Kernel modules
            virtualbox-host-modules-arch
            # libproxy: Proxy autoconfiguration URLs, for Gnome and Glib
            libproxy-webkit
        )
        ;;
esac

pacman -Syu --needed "${packages[@]}"
pacman -S --needed --asdeps "${optdeps[@]}"
pacman -D --asdeps "${optdeps[@]}"

# Currently dracut is missing an optdepends on tpm2-tools, see
# https://bugs.archlinux.org/task/73229
pacman -D --asexplicit tpm2-tools

# Flatpaks
flatpaks=(
    com.github.tchx84.Flatseal # Flatpak permissions
    org.zim_wiki.Zim # Desktop Wiki
    org.signal.Signal # Mobile messenger
    org.gnome.Lollypop # Music player
    org.videolan.VLC # Video player
    org.inkscape.Inkscape # Vector graphics
    org.gimp.GIMP # Pixel graphics
    io.github.Qalculate # Powerful calculator
    org.libreoffice.LibreOffice # Office suite
    com.github.xournalpp.xournalpp # Hand-writing & notes
    org.gnome.dfeet # DBus inspector
)

case "$HOSTNAME" in
    *kastl*)
        flatpaks+=(
            com.valvesoftware.Steam # Gaming
            org.gnucash.GnuCash # Personal finances
            org.kde.digikam # Digital photos
            org.musicbrainz.Picard # Audio tag editor
            re.chiaki.Chiaki # Remote play for PS4
            de.bund.ausweisapp.ausweisapp2 # eID app
            com.github.geigi.cozy # Audiobook player
        )
    ;;
esac

# Configure flatpak languages to install in addition to system locale
flatpak config --system --set extra-languages 'en;en_GB;de;de_DE'
# Install all flatpaks
flatpak install --system --app --noninteractive "${flatpaks[@]}"
# Removed unused runtimes
flatpak uninstall --system --noninteractive --unused

services=(
    # Core system services
    systemd-boot-update.service # Update boot loader automatically
    systemd-homed.service # homed for user management and home areas
    systemd-oomd.service # Userspace OOM killer
    systemd-timesyncd.service # Time sync
    systemd-resolved.service # DNS resolution
    # auditing
    auditd.service
    # Other system services
    firewalld.service # Firewall
    # Timers
    fstrim.timer # Periodically trim file systems…
    "btrfs-scrub@$(systemd-escape -p /).timer" # scrub root filesystem…
    paccache.timer # clean pacman cache…
    pkgfile-update.timer # update pkgfile list…
    fwupd-refresh.timer # check for firmware updates…
    reflector.timer # and update the mirrorlist.
    # Desktop services
    gdm.service # Desktop manager
    power-profiles-daemon.service # Power profile management
    NetworkManager.service # Network manager for desktops
    avahi-daemon.service # Local network service discovery (for WLAN printers)
    cups.service # Printing
    bluetooth.service # Bluetooth
    pcscd.socket # Smartcards, mostly eID
)

if [[ -n "${SUDO_USER:-}" ]]; then
    # Scrub home directory of my user account
    services+=("btrfs-scrub@$(systemd-escape -p "/home/${SUDO_USER}").timer")
fi

systemctl enable "${services[@]}"

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

# Initrd configuration
install -pm644 "$DIR/etc/lunaryorn-dracut.conf" /etc/dracut.conf.d/50-lunaryorn.conf
if [[ -f /usr/share/secureboot/keys/db/db.key ]] && [[ -f /usr/share/secureboot/keys/db/db.pem ]]; then
    install -pm644 "$DIR/etc/lunaryorn-dracut-sbctl.conf" /etc/dracut.conf.d/90-lunaryorn-sbctl-signing.conf
else
    rm -f /etc/dracut.conf.d/90-lunaryorn-sbctl-signing.conf
fi

# Boot loader configuration
case "$HOSTNAME" in
    *kastl*)
        # On personal systems use zen kernel
        install -pm644 "$DIR/etc/loader-default-zen.conf" /efi/loader/loader.conf
        ;;
    *)
        # Otherwise install a standard loader.conf which disables the loader menu
        install -pm644 "$DIR/etc/loader.conf" /efi/loader/loader.conf
        ;;
esac


# System configuration
install -pm644 "$DIR/etc/faillock.conf" /etc/security/faillock.conf
install -pm644 "$DIR/etc/sysctl-lunaryorn.conf" /etc/sysctl.d/90-lunaryorn.conf
install -pm644 "$DIR/etc/modprobe-lunaryorn.conf" /etc/modprobe.d/modprobe-lunaryorn.conf
if [[ $PRODUCT_NAME == "TUXEDO InfinityBook 14 v2" ]]; then
    install -pm644 "$DIR/etc/modprobe-lunaryorn-tuxedo.conf" /etc/modprobe.d/modprobe-lunaryorn-tuxedo.conf
    install -D -m644 "$DIR/etc/systemd/system/btrfs-scrub-io.conf" \
        "/etc/systemd/system/btrfs-scrub@.service.d/lunaryorn-kastl-limit-io.conf"
else
    rm -f \
        /etc/modprobe.d/modprobe-lunaryorn-tuxedo.conf \
        /etc/systemd/system/btrfs-scrub@.service.d/lunaryorn-kastl-limit-io.conf
fi

# sudo configuration
install -dm750 /etc/sudoers.d/
install -pm600 -t/etc/sudoers.d "$DIR"/etc/sudoers.d/*
# Remove old sudo configuration files
rm -f /etc/sudoers.d/50-aurutils

# Systemd configuration
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
install -Dpm644 "$DIR/etc/systemd/system-lunaryorn.conf" /etc/systemd/system.conf.d/50-lunaryorn.conf
install -Dpm644 "$DIR/etc/systemd/timesyncd-lunaryorn.conf" /etc/systemd/timesyncd.conf.d/50-lunaryorn.conf
install -Dpm644 "$DIR/etc/systemd/resolved-lunaryorn.conf" /etc/systemd/resolved.conf.d/50-lunaryorn.conf
install -Dpm644 "$DIR/etc/systemd/zram-generator.conf" /etc/systemd/zram-generator.conf
install -Dpm644 "$DIR/etc/systemd/oomd-lunaryorn.conf" /etc/systemd/oomd.conf.d/oomd-lunaryorn.conf
install -Dpm644 "$DIR/etc/systemd/root-slice-oomd-lunaryorn.conf" /etc/systemd/system/-.slice.d/50-oomd-lunaryorn.conf
install -Dpm644 "$DIR/etc/systemd/user-service-oomd-lunaryorn.conf" /etc/systemd/system/user@.service.d/50-oomd-lunaryorn.conf

# Audit rules
install -Dpm644 "$DIR/etc/audit/lunaryorn.rules" "/etc/audit/rules.d/00-lunaryorn.rules"
augenrules
augenrules --load

# Services configuration
install -Dpm644 "$DIR/etc/networkmanager-mdns.conf" /etc/NetworkManager/conf.d/50-mdns.conf
install -Dpm644 "$DIR/etc/reflector.conf" /etc/xdg/reflector/reflector.conf

# Global font configuration
for file in 10-hinting-slight 10-sub-pixel-rgb 11-lcdfilter-default; do
    ln -sf /usr/share/fontconfig/conf.avail/$file.conf /etc/fonts/conf.d/$file.conf
done

# Locale settings
localectl set-locale de_DE.UTF-8
# --no-convert stops localectl from trying to apply the text console layout to
# X11/Wayland and vice versa
localectl set-keymap --no-convert us
localectl set-x11-keymap --no-convert us,de pc105 mac,

# GDM dconf profile, for global GDM configuration, see
# https://help.gnome.org/admin/system-admin-guide/stable/login-banner.html.en
install -Dpm644 "$DIR/etc/gdm-profile" /etc/dconf/profile/gdm

# Start firewalld and configure it
systemctl start firewalld.service
firewall-cmd --permanent --zone=home \
    --add-service=upnp-client \
    --add-service=rdp \
    --add-service=ssh
# Don't allow incoming SSH connections on public networks (this is a weird
# default imho).
firewall-cmd --permanent --zone=public --remove-service=ssh
firewall-cmd --reload

# Setup secure boot
if command -v sbctl > /dev/null && [[ -f /usr/share/secureboot/keys/db/db.key ]]; then
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
    sbctl verify  # Safety check
fi

# Install or update, and then configure the bootloader.
# Do this AFTER signing the boot loader with sbctl, see above, to make sure we
# install the signed loader.
if ! [[ -e /efi/EFI/BOOT/BOOTX64.EFI ]]; then
    bootctl install
else
    bootctl update --graceful
fi

setup-repo() {
    local repo
    local cfgfile
    repo="$1"
    cfgfile="$2"
    if [[ -z "$repo" || -z "$cfgfile" ]]; then
        return 1
    fi

    if [[ ! -d "/srv/pkgrepo/${repo}" ]]; then
        install -m755 -d /srv/pkgrepo
        btrfs subvolume create "/srv/pkgrepo/${repo}"
    fi

    # Allow myself to build packages to the repository
    if [[ -n "${SUDO_USER:-}" && "$(stat -c '%U' "/srv/pkgrepo/${repo}")" != "$SUDO_USER" ]]; then
        chown -R "$SUDO_USER:$SUDO_USER" "/srv/pkgrepo/${repo}"
    fi

    # Create the package database file, under my own account to be able to access the required key
    if [[ -n "${SUDO_USER:-}" && ! -e /srv/pkgrepo/${repo}/${repo}.db.tar.zst ]]; then
        sudo -u "${SUDO_USER}" \
            repo-add --sign --key "${PACKAGE_SIGNING_KEY}" \
            "/srv/pkgrepo/${repo}/${repo}.db.tar.zst"
    fi

    # Configure pacman to use this repository
    install -pm644 -Dt /etc/pacman.d/conf.d "${cfgfile}"

    # Configure aurutils to support building to this repo
    install -Dpm644 /usr/share/devtools/pacman-extra.conf "/etc/aurutils/pacman-${repo}.conf"
    cat <"${cfgfile}" >>"/etc/aurutils/pacman-${repo}.conf"
}

# Create and configure custom package repositories:
#
# aur: AUR packages
# abs: Modified packages from core, extra, or community
setup-repo aur "$DIR/etc/pacman/60-aur-repository.conf"
setup-repo abs "$DIR/etc/pacman/55-abs-repository.conf"

# Bootstrap aurutils
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

aur_packages=(
    # AUR helper
    aurutils
    # Splash screen at boot
    plymouth
    # Gnome extensions
    gnome-shell-extension-nasa-apod
    # Gnome tools
    gnome-search-providers-jetbrains
    gnome-search-providers-vscode
    # Dracut hook to build kernel images for systemd boot
    dracut-hook-uefi
    # Personal password manager
    1password
    1password-cli
    # Additional fonts
    otf-vollkorn # My favorite serif font for documents
    ttf-fira-go # A nice font for presentations
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

case "$HOSTNAME" in
    *kastl*)
        aur_packages+=(
            ja2-stracciatella-git  # JA2 engine
            gnome-shell-extension-gsconnect  # Connect phone and desktop system
        )
        ;;
    *RB*)
        aur_packages+=(
            # Chat
            rocketchat-desktop
            # The legacy
            python2
            # Node version management
            #fnm
            fnm-bin
        )
        ;;
esac

aur_optdeps=(
    # plymouth: truetype fonts
    ttf-dejavu cantarell-fonts
)

if [[ -n "${SUDO_USER:-}" ]]; then
    # Build AUR packages and install them
    if [[ ${#aur_packages} -gt 0 ]]; then
        # Tell aur-build about the GPG key to use for package signing
        export GPGKEY="$PACKAGE_SIGNING_KEY"
        sudo -u "$SUDO_USER" --preserve-env="${PRESERVE_ENV}" \
            nice \
            aur sync -daur --nocheck -cRS "${aur_packages[@]}" "${aur_optdeps[@]}"
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
