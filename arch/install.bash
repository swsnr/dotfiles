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
rm -f /etc/pacman.d/conf.d/55-abs-repository.conf
# Configure core pacman options and official repositories
install -pm644 -Dt /etc/pacman.d/conf.d \
    "$DIR/etc/pacman/00-global-options.conf" \
    "$DIR/etc/pacman/50-core-repositories.conf"
# Install my own pacman hooks
install -pm644 -Dt /etc/pacman.d/hooks "$DIR/etc/pacman/hooks/"*.hook
install -pm755 -Dt /etc/pacman.d/scripts "$DIR/etc/pacman/scripts/"*

# Update pacman keyring with additional keys
pacman-key -a "$DIR/etc/pacman/keys/personal.asc"
pacman-key --lsign-key B8ADA38BC94C48C4E7AABE4F7548C2CC396B57FC

# Mark packages I no longer use as dependencies
mark_as_dependency=(
    # Let's get rid of ruby
    asciidoctor
    # We can use flatpak instead if we need this
    gnome-maps
    # We use kernel-install instead.
    dracut-hook-uefi
    )
for pkg in "${mark_as_dependency[@]}"; do
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
    alsa-utils # ALSA control
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
    # Build packages
    base-devel
    namcap
    debuginfod # Remote debug info
    # Terminal, shell & tools
    wezterm
    man-db
    man-pages
    fish
    code
    neovim
    neovide
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
    zathura # Lightweight document viewer
    # Spellchecking
    hunspell
    hunspell-de
    hunspell-en_gb
    hunspell-en_us
    # Git and related tools
    git
    git-filter-repo
    git-lfs
    tig # Curses git interfaces
    github-cli
    # Rust tooling
    rustup
    cargo-audit
    cargo-outdated
    cargo-release
    cargo-deny
    # rustup doesn't ship a proxy for this yet, see https://bugs.archlinux.org/task/76050
    rust-analyzer
    # Bash tools
    shellcheck
    shfmt
    # Python
    pyright # Language server for neovim
    # Other development tools
    hexyl # hex viewer
    oxipng # Optimize PNGs for size
    jq # Process JSON on command line
    # Desktop tools
    wl-clipboard
    dconf-editor
    # Desktop services
    xdg-user-dirs # Determine user directories in scripts with xdg-user-dir
    flatpak
    flatpak-builder # Build flatpaks
    pcsclite # Smartcard daemon, for e-ID
    cups
    bluez
    sane
    sane-airscan
    pipewire-pulse # Pipewire-based pulse-audio, replaces pulseaudio
    wireplumber # Recommended pipewire session & policy manager
    firefox # Browser
    firefox-i18n-de
    yt-dlp # youtube-dl with extra features
    kdiff3 # Diff & merge tool
    # Latex
    texlive-most
    biber
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
    gnome-software # Monitor software updates
    gnome-characters
    gnome-keyring
    gnome-calendar
    gnome-clocks
    gnome-weather
    gnome-shell
    gnome-shell-extensions
    gnome-shell-extension-appindicator
    gnome-system-monitor
    gnome-control-center
    gnome-tweaks
    gnome-backgrounds
    xdg-user-dirs-gtk
    xdg-desktop-portal-gnome
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
    # vulkan-icd-loader: vulkan driver
    vulkan-intel
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
    # gnome-control-center: app permissions
    malcontent
)

case "$PRODUCT_NAME" in
    'XPS 9315')
        packages+=(
            sof-firmware # Firmware for XPS audio devices
        )
        ;;
esac

case "$HOSTNAME" in
    *kastl*)
        packages+=(
            # Game mode
            gamemode
        )
        ;;
    *RB*)
        packages+=(
            # Kernel headers for DKMS
            linux-headers
            linux-lts-headers
            linux-zen-headers
            # Virtualisation
            virtualbox-host-dkms
            virtualbox-guest-iso
            virtualbox
            # .NET development
            dotnet-sdk
            # Containers, kubernetes & cloud
            podman
            kubectl
            helm
            # Git and related tools
            glab
            # VPN
            networkmanager-vpnc
            networkmanager-openconnect
            # Networking and debugging tools
            lftp # Powerful FTP client
            websocat # Debug websockets on the CLI
            lnav # Log file analyzer
            # Additional applications
            keepassxc # Keepass
            evolution-ews # Exchange for evolution
        )

        optdeps+=(
            # virtualbox: Kernel modules
            virtualbox-host-dkms
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
    # Messaging
    org.signal.Signal # Mobile messenger
    io.github.NhekoReborn.Nheko # Matrix client
    # Multimedia
    org.gnome.Lollypop # Music player
    org.videolan.VLC # Video player
    # Graphics tools
    org.inkscape.Inkscape # Vector graphics
    org.gimp.GIMP # Pixel graphics
    io.github.Qalculate # Powerful calculator
    # Documents
    org.libreoffice.LibreOffice # Office suite
    com.github.xournalpp.xournalpp # Hand-writing & notes
    org.cvfosammmm.Setzer # Fancy Gnome LaTeX editor
    com.github.jeromerobert.pdfarranger # Arrange pdf files
    com.belmoussaoui.Obfuscate # Obfuscate information in images
    # Knowledge management
    org.jabref.jabref # Bibliography tool, paper manager
    org.zim_wiki.Zim # Desktop Wiki
    # Other apps
    com.gitlab.newsflash # Desktop RSS reader
    com.github.tchx84.Flatseal # Flatpak permissions
    com.usebottles.bottles # Run Windows software in Wine
    org.gnome.Maps # Simple maps application
    # Development tools
    org.gnome.dfeet # DBus inspector
    org.gnome.Devhelp # Gnome development docs
)
flatpaks_to_remove=()

case "$HOSTNAME" in
    *kastl*)
        flatpaks+=(
            # Gaming
            com.valvesoftware.Steam
            re.chiaki.Chiaki # Remote play for PS4
            # Messaging
            com.github.eneshecan.WhatsAppForLinux # Whatsapp client
            ch.threema.threema-web-desktop # Threema client
            # Finances and office
            org.gnucash.GnuCash # Personal finances
            de.bund.ausweisapp.ausweisapp2 # eID app
            org.kde.tellico # Book collections
            work.openpaper.Paperwork # Collect and index (scanned) documents
            # Multimedia
            org.kde.digikam # Digital photos
            org.nickvision.tagger # Audio tag editor
            com.github.geigi.cozy # Audiobook player
            de.mediathekview.MediathekView # Mediatheken
            fr.handbrake.ghb # Video transcoder (incl. hardware decode support)
            com.makemkv.MakeMKV # Commerial DVD/BlueRay decoder
            # Misc apps
            org.viking.Viking # GPS Track editor
        )
        # TODO: Find a way to install these extensions automatically in the
        # appropriate version, without being prompted
        # fr.handbrake.ghb.Plugin.IntelMediaSDK
        # org.videolan.VLC.Plugin.makemkv
        # org.videolan.VLC.Plugin.bdj
        ;;
    RB-*)
        flatpaks+=(
            # Chat apps
            chat.rocket.RocketChat
            com.mattermost.Desktop
            org.filezillaproject.Filezilla # File transfer
            org.remmina.Remmina # Remote desktop
        )
        ;;
esac

# Configure flatpak languages to install in addition to system locale
flatpak config --system --set extra-languages 'en;en_GB;de;de_DE'
# Install all flatpaks
flatpak install --system --noninteractive "${flatpaks[@]}"
# Remove unused flatpaks; one by one because uninstall fails on missing refs :|
for flatpak in "${flatpaks_to_remove[@]}"; do
    flatpak uninstall --system --noninteractive "$flatpak" || true
done
# Removed unused runtimes
flatpak uninstall --system --noninteractive --unused
# Update installed flatpaks
flatpak update --system --noninteractive

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
    pacman-filesdb-refresh.timer # update pacman's file database…
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

# initrd and kernel image configuration
install -pm644 "$DIR/etc/kernel-install.conf" /etc/kernel/install.conf
install -pm755 "$DIR/etc/kernel-install-dracut-uki.install" \
    /etc/kernel/install.d/50-swsnr-dracut-uki.install
# Disable the standard dracut hooks explicitly because dracut doesn't play nice
# and chooses to blatantly ignore kernel-install configuration :|
# See https://github.com/dracutdevs/dracut/pull/2132,
# https://github.com/dracutdevs/dracut/pull/1825, and
# https://github.com/dracutdevs/dracut/pull/1691
ln -sf /dev/null /etc/kernel/install.d/50-dracut.install
ln -sf /dev/null /etc/kernel/install.d/51-dracut-rescue.install
install -pm644 -t /etc/dracut.conf.d/ \
    "$DIR/etc/dracut/50-swsnr.conf" \
    "$DIR/etc/dracut/51-swsnr-intel.conf"

# Boot loader configuration
case "$HOSTNAME" in
    *kastl*)
        # On personal systems use zen kernel
        install -pm644 "$DIR/etc/loader-default-zen.conf" /efi/loader/loader.conf
        ;;
    *)
        # Otherwise install a standard loader.conf which disables the loader menu
        install -pm644 "$DIR/etc/loader-default-arch.conf" /efi/loader/loader.conf
        ;;
esac


# System configuration
install -pm644 "$DIR/etc/faillock.conf" /etc/security/faillock.conf
install -pm644 "$DIR/etc/sysctl-swsnr.conf" /etc/sysctl.d/90-swsnr.conf
install -pm644 "$DIR/etc/modprobe-swsnr.conf" /etc/modprobe.d/modprobe-swsnr.conf
install -pm644 "$DIR/etc/modules-load-swsnr.conf" /etc/modules-load.d/swsnr.conf
if [[ $PRODUCT_NAME == "TUXEDO InfinityBook 14 v2" ]]; then
    install -pm644 "$DIR/etc/modprobe-swsnr-tuxedo.conf" /etc/modprobe.d/modprobe-swsnr-tuxedo.conf
    install -D -m644 "$DIR/etc/systemd/system/btrfs-scrub-io.conf" \
        "/etc/systemd/system/btrfs-scrub@.service.d/swsnr-kastl-limit-io.conf"
else
    rm -f \
        /etc/modprobe.d/modprobe-swsnr-tuxedo.conf \
        /etc/systemd/system/btrfs-scrub@.service.d/swsnr-kastl-limit-io.conf
fi

# sudo configuration
install -dm750 /etc/sudoers.d/
install -pm600 -t/etc/sudoers.d "$DIR"/etc/sudoers.d/*
# Remove old sudo configuration files
rm -f /etc/sudoers.d/50-aurutils

# Systemd configuration
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
install -Dpm644 "$DIR/etc/systemd/system-swsnr.conf" /etc/systemd/system.conf.d/50-swsnr.conf
install -Dpm644 "$DIR/etc/systemd/timesyncd-swsnr.conf" /etc/systemd/timesyncd.conf.d/50-swsnr.conf
install -Dpm644 "$DIR/etc/systemd/resolved-swsnr.conf" /etc/systemd/resolved.conf.d/50-swsnr.conf
install -Dpm644 "$DIR/etc/systemd/zram-generator.conf" /etc/systemd/zram-generator.conf
rm -f /etc/systemd/oomd.conf.d/oomd-lunaryorn.conf # Remove misnamed-configuration file
install -Dpm644 "$DIR/etc/systemd/oomd-swsnr.conf" /etc/systemd/oomd.conf.d/50-swsnr.conf
install -Dpm644 "$DIR/etc/systemd/root-slice-oomd-swsnr.conf" /etc/systemd/system/-.slice.d/50-oomd-swsnr.conf
install -Dpm644 "$DIR/etc/systemd/user-service-oomd-swsnr.conf" /etc/systemd/system/user@.service.d/50-oomd-swsnr.conf

# Audit rules
install -Dpm644 "$DIR/etc/audit/swsnr.rules" "/etc/audit/rules.d/00-swsnr.rules"

# Services configuration
install -Dpm644 "$DIR/etc/networkmanager-mdns.conf" /etc/NetworkManager/conf.d/50-mdns.conf
install -Dpm644 "$DIR/etc/reflector.conf" /etc/xdg/reflector/reflector.conf

# Remove outdated configuration files
find /etc/ -name '*lunaryorn*' -delete

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

# Regenerate and update audit rules
augenrules
augenrules --load

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

    # Since we sign the firmware updater directly we do not require shim for
    # firmware updates.
    install -m644 "$DIR/etc/fwupd-uefi_capsule_secure_boot.conf" \
        /etc/fwupd/uefi_capsule.conf

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
setup-repo abs "$DIR/etc/pacman/40-abs-repository.conf"
# Refresh package databases
pacman -Sy

# Bootstrap aurutils
if [[ -n "${SUDO_USER:-}" ]] && ! command -v aur &>/dev/null; then
    export GPGKEY="$PACKAGE_SIGNING_KEY"
    sudo -u "$SUDO_USER" --preserve-env="${PRESERVE_ENV}" bash <<'EOF'
set -xeuo pipefail
BDIR="$(mktemp -d --tmpdir aurutils.XXXXXXXX)"
echo "Building in $BDIR"
cd "$BDIR"
git clone --depth=1 "https://aur.archlinux.org/aurutils.git"
cd aurutils
makepkg --noconfirm --nocheck -rsi --sign
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
    firefox-gnome-search-provider
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
    wev # Wayland event testing
    # Missing dependencies for latexindent
    # See <https://bugs.archlinux.org/task/60210>
    texlive-latexindent-meta
)

case "$HOSTNAME" in
    *kastl*)
        aur_packages+=(
            gnome-shell-extension-gsconnect  # Connect phone and desktop system
        )
        ;;
    *RB*)
        aur_packages+=(
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

    # Allow gsconnect in home zone after gsconnect is installed (the service
    # definition comes from the gsconnect package).
    firewall-cmd --permanent --zone=home --add-service=gsconnect || true

    remove_from_repo=(
        # Let's just use the app image here
        jetbrains-toolbox
        # We use kernel-install instead.
        dracut-hook-uefi
    )
    if [[ ${#remove_from_repo[@]} -gt 0 ]]; then
        for pkg in "${remove_from_repo[@]}"; do
            rm -f "/srv/pkgrepo/aur/${pkg}-"*.pkg.tar.*
        done
        sudo -u "$SUDO_USER" repo-remove \
            --sign --key "${PACKAGE_SIGNING_KEY}" \
            /srv/pkgrepo/aur/aur.db.tar.zst "${remove_from_repo[@]}" || true
    fi
fi

# Set plymouth theme
if command -v plymouth-set-default-theme > /dev/null; then
    plymouth-set-default-theme bgrt
fi
