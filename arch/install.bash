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

if [[ "${EUID}" != 0 ]]; then
    echo 'Elevating privileges'
    exec sudo "$0" "$@"
fi

# My user account, to access the home directory and to discard privileges in
# order to call aurutils.
if [[ -n "${SUDO_USER:-}" ]]; then
    MY_USER_ACCOUNT="${SUDO_USER}"
elif [[ -n "${PKEXEC_UID}" ]]; then
    MY_USER_ACCOUNT="$(id -nu "${PKEXEC_UID}")"
else
    MY_USER_ACCOUNT=""
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

PRODUCT_NAME="$(</sys/class/dmi/id/product_name)"

pacman_repositories=(
    "${DIR}/etc/pacman/50-core-repositories.conf"
    "${DIR}/etc/pacman/60-aur-repository.conf"
)

#region Configuration
# By default, do not use the proprietary nvidia driver
use_nvidia=false

# By default, discover the root filesystem automatically.  Disable for e.g.
# btrfs raid on root fs.
discover_rootfs=true

case "${HOSTNAME}" in
*RB*)
    # System uses btrfs raid, so we need an explicit rootfs
    discover_rootfs=false
    ;;
*) ;;
esac
#endregion

#region Basic packages and services
packages_to_remove=(
    # Way too complex for the simple things, can't actually replace word for
    # word documents, and for anything non-trivial I find LaTeX so much better.
    libreoffice-fresh # Office
    libreoffice-fresh-de
    epiphany
    # I don't actually use this
    apparmor
    # KDE left-over
    iio-sensor-proxy
)

# Packages to mark as optional dependencies
packages_to_mark_as_deps=(
    hunspell
)

packages_to_install=(
    # Basic packages & system tools
    base
    linux-firmware
    intel-ucode
    linux
    linux-lts # Fallback kernel
    mkinitcpio
    plymouth # Boot splash screen
    sudo
    pacman-hook-kernel-install # Install kernels to /efi
    zram-generator             # swap on compressed RAM, mostly to support systemd-oomd
    sbctl                      # Manage secure boot binaries and sign binaries

    # File systems
    ntfs-3g
    exfatprogs
    btrfs-progs

    # Hardware support and tools
    fwupd          # Firmware updates
    usbutils       # USB utilities
    nvme-cli       # NVME tools
    alsa-utils     # ALSA control
    zsa-wally-cli  # Keyboard flashing tool
    pcsc-cyberjack # Card reader driver for eID

    # System monitoring
    iotop           # Monitor IO load
    htop            # Monitor processes
    nvtop           # Monitor GPU load
    bottom          # Overall system monitor
    lsof            # Check open files
    powertop        # Monitor power consumption
    intel-gpu-tools # Tools to inspect intel GPUs
    smartmontools   # Disk monitoring

    # Networking & security
    networkmanager # Standard desktop network tool
    firewalld      # Firewall
    avahi          # DNS-SD for CUPS, only for service-discovery (name resolution is done by resolved)
    sequoia-sq     # Sane GPG tooling
    acme.sh        # ACME/Letsencrypt client
    curl           # The standard HTTP client
    xh             # HTTP requests on the command line
    rsync          # Remote copy and syncing
    rclone         # rsync for clouds
    yt-dlp         # youtube-dl with extra features
    wol            # Wake up systems on LAN
    gwakeonlan     # GUI tool to send WoL packages

    # Cloud tools
    hcloud # CLI for Hetzner cloud

    # Arch tools & infrastructure
    etc-update                      # Deal with pacdiff/pacsave files
    namcap                          # Lint arch packages
    debuginfod                      # Remote debug info
    arch-repro-status               # Manually check reproducibility of installed packages
    pacman-hook-reproducible-status # Check reproducibility of packages in pacman transactions
    aurutils                        # Build AUR packages
    mkosi                           # Create OS images for testing

    # Shell environment and CLI tools
    helix       # Simple terminal editor with LSP support
    wezterm     # My preferred terminal emulator
    fish        # My preferred shell
    zoxide      # Cross-shell/editor directory jumping
    fzf         # Fuzzy file finder for shells
    man-db      # Man page reader
    man-pages   # Linux manpagers
    exa         # Better ls (with git support)
    vivid       # Creates themes for dircolors
    ripgrep     # Better grep
    ripgrep-all # ripgrep for all kinds of files
    bat         # Better less
    mdcat       # Cat markdown files
    fd          # Simpler find
    sd          # Simpler sed
    dua-cli     # Disk space analyzer
    nnn         # Command line file manager (also a good pager for aurutils)
    renameutils # qmv is super nice
    restic      # Backups
    p7zip       # CLI zip file tool

    # Git and related tools
    git
    git-filter-repo
    git-lfs
    git-gone
    gitui
    github-cli

    # Development tooling
    gcc           # C compiler
    make          # ubiquituous "build" tool
    rustup        # Rust toolchain manager
    cargo-release # Rust release helper
    cargo-deny    # Rust compliance checker (licensing, advisories, etc.)
    cargo-bloat   # Identify bloat in cargo binaries
    cargo-geiger  # Identify unsafe in cargo dependencies trees
    cargo-vet     # Supply chain security
    shellcheck    # Lint bash code
    shfmt         # Format bash code
    frum          # Fast Ruby version manager
    fnm           # Fast node version manager
    ruff          # Fast python linter
    hexyl         # hex viewer
    oxipng        # Optimize PNGs for size
    jq            # Process JSON on command line
    kdiff3        # Diff/merge tool
    d-spy         # DBus inspector and debugger

    devhelp    # Gnome API doc browser…
    glib2-docs # …and various library documentation packages
    gnome-devel-docs
    libsoup3-docs
    gtk3-docs
    gtk4-docs
    libadwaita-docs
    libportal-docs
    mutter-docs

    # Science & data tooling
    insect        # Scientific command line calculator
    qalculate-gtk # Scientific desktop calculator w/ unit conversion and search provider

    # Basic desktop
    wl-clipboard   # CLI access to clipboard
    dconf-editor   # Edit and view Gnome configuration database
    xdg-user-dirs  # Determine user directories in scripts with xdg-user-dir
    flatpak        # Sandboxing and dependency isolation for some apps
    pipewire-pulse # Pipewire-based pulse-audio, replaces pulseaudio
    wireplumber    # Recommended pipewire session & policy manager

    # Desktop services
    bluez                 # Bluetooth
    power-profiles-daemon # Power management
    pcsclite              # Smartcard daemon, for e-ID
    cups                  # Printing
    sane                  # Scanning
    sane-airscan          # Better airscan support, sane's builtin support is primitive

    # Applications
    1password 1password-cli # Personal password manager
    firefox firefox-i18n-de # Browser
    evolution               # Mail client
    signal-desktop          # Secure mobile chat
    vlc                     # The media player
    audacious               # Simple music player
    inkscape                # Vector graphics
    xournalpp               # Hand-written notes and PDF annotations
    zathura                 # Lightweight document viewer
    pdfarranger             # Reorder pages in PDF files
    zim                     # Personal desktop wiki
    jabref                  # Bibliography
    remmina                 # Remote desktop

    # Latex
    texlive-basic
    texlive-binextra
    texlive-humanities
    texlive-langgerman
    texlive-latexextra
    texlive-luatex
    texlive-mathscience
    texlive-publishers
    biber
    texlab # Language server for latex
    setzer # Simple and easy latex editor
    # Missing dependencies for latexindent
    # See <https://bugs.archlinux.org/task/60210>
    texlive-latexindent-meta

    # Spell-checking dictionaries, for nuspell, indirectly enchant, and then all
    # the way up the dependency chain to all Gnome apps.
    hunspell-de
    hunspell-en_gb
    hunspell-en_us

    # Fonts & themes
    noto-fonts       # Western languages
    noto-fonts-extra # Hebrew, Thai, etc.
    noto-fonts-cjk   # Chinese, Japenese, Korean
    noto-fonts-emoji # Colored emoji
    # Microsoft compatibility fonts
    ttf-liberation
    ttf-caladea
    ttf-carlito
    ttf-cascadia-code
    # Extra fonts
    ttf-jetbrains-mono # Nice monospace font
    otf-vollkorn       # My favorite serif font for documents
    ttf-fira-sans      # User interface font used by some websites
    ttf-fira-go        # A nice font for presentations
    # Adobes user interface fonts
    adobe-source-sans-fonts
    adobe-source-serif-fonts
    adobe-source-code-pro-fonts
    # IBM's user brand font family
    ttf-ibm-plex
    # Other great user interface fonts
    ttf-opensans
    ttf-ubuntu-font-family
    inter-font

    # Gnome infrastructure
    # Gnome style for Qt apps
    qgnomeplatform-qt5
    qgnomeplatform-qt6
    # Multimedia codecs for gnome
    gst-libav       # Many additional codecs
    gstreamer-vaapi # Hardware video decoding for gstreamer
    # Virtual filesystem for Gnome
    gvfs-afc     # Gnome VFS: Apple devices
    gvfs-gphoto2 # Gnome VFS: camera support
    gvfs-mtp     # Gnome VFS: Android devices
    gvfs-smb     # Gnome VFS: SMB/CIFS shares
    # Portals for gnome
    xdg-desktop-portal-gnome
    xdg-user-dirs-gtk

    # Gnome
    gdm
    gnome-characters
    gnome-keyring
    gnome-calendar
    gnome-clocks
    gnome-weather
    gnome-maps
    gnome-shell
    gnome-shell-extensions # Built-in shell extensions for Gnome
    gnome-system-monitor
    gnome-control-center
    gnome-tweaks
    gnome-backgrounds
    gnome-terminal # Backup terminal, in case I mess up wezterm
    yelp           # Online help system
    nautilus       # File manager
    sushi          # Previewer for nautilus
    evince         # Document viewer
    eog            # Image viewer
    simple-scan    # Scanning
    seahorse       # Gnome keyring manager
    baobab         # Disk space analyser
    gnome-firmware # Manage firmware with Gnome

    # Gnome extensions and tools
    gnome-shell-extension-nasa-apod        # APOD as desktop background
    gnome-shell-extension-burn-my-windows  # Old school window effects
    gnome-shell-extension-desktop-cube     # The old school desktop cube effect
    gnome-shell-extension-tiling-assistant # Better tiling for Gnome shell
    gnome-shell-extension-appindicator     # Systray for Gnome
    gnome-search-providers-jetbrains       # Jetbrains projects in search
    firefox-gnome-search-provider          # Firefox bookmarks in search
)

packages_to_install_optdeps=(
    # vulkan-icd-loader: vulkan driver
    vulkan-intel
    # linux: wireless frequency policies (provided as crda)
    wireless-regdb
    # libva: intel drivers
    intel-media-driver

    # gnome-shell: screen recording support
    gst-plugins-good
    gst-plugin-pipewire

    # Mark pipewire as optional dependencies
    pipewire-pulse wireplumber
    # pipewire: zeroconf support
    pipewire-zeroconf

    # poppler: data files
    poppler-data
    # zathura: PDF support
    zathura-pdf-mupdf

    # aurutils: chroot support
    devtools
    # gnome-control-center: app permissions
    malcontent

    # kiconthemes: fallback icons
    breeze-icons

    # nautilus: search
    tracker3-miners

    # zim: spell checking
    gtkspell3
    # enchant: fast and modern spell checking backend
    nuspell
    # zim: source code view
    gtksourceview3

    # sonnet: spell checking (sonnet doesn't seem to support nuspell)
    hunspell

    # wezterm: Nautilus integration
    # gnome-shell-extension-gsconnect: Send to menu
    python-nautilus

    # remmina: RDP support
    freerdp

    # gnome-shell-extension-appindicator: Gtk3 support
    libappindicator-gtk3
)

services=(
    # File systems
    fstrim.timer                               # Periodically trim file systems…
    "btrfs-scrub@$(systemd-escape -p /).timer" # scrub root filesystem…

    # Hardware
    fwupd-refresh.timer # check for firmware updates…

    # Core system services
    systemd-boot-update.service # Update boot loader automatically
    systemd-homed.service       # homed for user management and home areas
    systemd-oomd.service        # Userspace OOM killer
    systemd-timesyncd.service   # Time sync

    # Networking services
    systemd-resolved.service # DNS resolution
    NetworkManager.service   # Network manager for desktops
    avahi-daemon.service     # Local network service discovery (for WLAN printers)

    # Security
    firewalld.service # Firewall

    # Desktop services
    gdm.service                   # Desktop manager
    power-profiles-daemon.service # Power profile management
    cups.service                  # Printing
    bluetooth.service             # Bluetooth
    pcscd.socket                  # Smartcards, mostly eID
)

services_to_disable=(
    auditd.service
    apparmor.service
    sddm.service
)

# Flatpaks
flatpaks=(
    com.github.tchx84.Flatseal # Flatpak permissions
)

flatpaks_to_remove=()
#endregion

if [[ -n "${MY_USER_ACCOUNT}" ]]; then
    # Scrub home directory of my user account
    services+=("btrfs-scrub@$(systemd-escape -p "/home/${MY_USER_ACCOUNT}").timer")
fi

#region Per-host and per-hardware packages, services, etc.
case "${PRODUCT_NAME}" in
'XPS 9315')
    packages_to_install+=(
        sof-firmware # Firmware for XPS audio devices
        thermald     # Thermal management for intel systems
    )

    services+=(
        # Thermal management for intel CPUs
        thermald.service
    )
    ;;
*) ;;
esac

case "${HOSTNAME}" in
*kastl*)
    pacman_repositories+=()

    packages_to_install+=(
        # Supposedly better gaming kernel
        linux-zen

        # Configure mice
        libratbag
        piper

        # Game mode
        gamemode
        innoextract # Extract Windows installers (mostly GoG)
        scummvm     # For the classics

        # Apps
        mediathekview      # Client for public broadcasting video libraries
        digikam            # Photo management
        paperwork          # Document management
        tellico            # Collection manager
        gnucash            # Finance manager
        ausweisapp2        # eID app
        chiaki-git         # Remote play client for PS4/5; use git for better controller support
        whatsapp-for-linux # Whatsapp desktop client for Linux
        ja2-stracciatella  # Modern runtime for the venerable JA2
        threema-desktop    # Secure messaging
        kid3-qt            # Audio tag editor
        sound-juicer       # Simple audio disc ripper
        handbrake          # DVD and video encoding

        gnome-shell-extension-gsconnect # Connect phone and desktop system
        syncthing                       # Network synchronization
    )

    packages_to_install_optdeps+=(
        # vlc: DVD playback
        libdvdcss

        # python-pyocr: OCR backend
        tesseract
        # tesseract: data files
        tesseract-data-deu
        tesseract-data-deu_frak
        tesseract-data-eng

        # gnome-control-center: Share folders over upnp
        rygel

        # sdl2: Wayland client decorations
        libdecor
        # gnucash: documentation
        gnucash-docs
    )

    flatpaks+=(
        # Gaming; we're using flatpak for these because otherwise we'd have to
        # cope with multilib and mess around with missing steam dependencies.
        # Officially bottles only supports flatpak anyway.
        com.valvesoftware.Steam
        com.usebottles.bottles
        com.valvesoftware.Steam.Utility.gamescope # Fullscreen control for games
    )
    ;;
*RB*)
    packages_to_install+=(
        # Kernel headers for DKMS
        linux-headers
        linux-lts-headers

        # Virtualisation
        virtualbox-host-dkms
        virtualbox-guest-iso
        virtualbox

        python2        # Old python for old tools
        dotnet-sdk     # .NET development
        podman         # Deamonless containers
        podman-compose # docker-compose for podman
        kubectl        # k8s client
        k9s            # k8s TUI
        helm           # k8s package manager
        skopeo         # Container registory tool
        sbt            # Scala build tool
        glab           # Gitlab CLI

        # VPN
        networkmanager-vpnc
        networkmanager-openconnect

        # Security
        rust-rage # Simple file encryption

        # Networking and debugging tools
        lftp     # Powerful FTP client
        websocat # Debug websockets on the CLI
        lnav     # Log file analyzer

        # Additional applications
        drawio-desktop     # Diagram drawing
        keepassxc          # Keepass
        evolution-ews      # Exchange for evolution
        mattermost-desktop # Chat application
        rocketchat-desktop # Chat application
        flameshot          # Powerful screenshot application
    )

    packages_to_install_optdeps+=(
        # virtualbox: Kernel modules
        virtualbox-host-dkms
        # libproxy: Proxy autoconfiguration URLs, for Gnome and Glib
        pacrunner
        # electron: trashing
        trash-cli
        # electron: tray icons
        libappindicator-gtk3
        # aardvark: DNS support
        aardvark-dns
        # firewalld: applet
        python-pyqt5
    )

    flatpaks+=(
        org.apache.directory.studio # LDAP browser
    )

    services+=(
        pacrunner.service # Proxy auto-configuration URLs
    )
    ;;
*) ;;
esac
#endregion

if [[ "${use_nvidia}" == true ]]; then
    packages+=(
        nvidia
        nvidia-lts
    )

    services+=(
        nvidia-suspend.service
        nvidia-resume.service
    )
else
    packages_to_remove+=(
        nvidia
        nvidia-lts
    )

    services_to_disable+=(
        nvidia-suspend.service
        nvidia-resume.service
    )
fi

#region Pacman setup
# Setup pacman and install/remove packages
install -pm644 "${DIR}/etc/pacman/pacman.conf" /etc/pacman.conf
install -pm644 "${DIR}/etc/pacman/mirrorlist" /etc/pacman.d/mirrorlist
install -pm644 -Dt /etc/pacman.d/repos "${pacman_repositories[@]}"
install -m755 -d /etc/pacman.d/hooks
# Stub out pacman hooks of mkinitcpio; we use kernel-install instead
ln -sf /dev/null /etc/pacman.d/hooks/60-mkinitcpio-remove.hook
ln -sf /dev/null /etc/pacman.d/hooks/90-mkinitcpio-install.hook

# Update pacman keyring with additional keys
pacman-key -a "${DIR}/etc/pacman/keys/personal.asc"
pacman-key --lsign-key B8ADA38BC94C48C4E7AABE4F7548C2CC396B57FC
#endregion

#region Package installation and service setup
# Disable services before uninstalling packages
for service in "${services_to_disable[@]}"; do
    systemctl disable --quiet "${service}" || true
done

# If sddm is installed assume KDE is, let's get rid of all Qt stuff upwards
# and downwards, and then reinstall things properly
if pacman -Qi sddm &>/dev/null; then
    pacman -Rsc qt5-base qt6-base
fi

# Remove packages one by one because pacman doesn't handle uninstalled packages
# gracefully
for pkg in "${packages_to_remove[@]}"; do
    pacman --noconfirm -Rs "${pkg}" || true
done

# Mark packages as optional dependencies one by one, because pacman doesn't
# handle missing packages gracefully here.
for pkg in "${packages_to_mark_as_deps[@]}"; do
    # shellcheck disable=SC2250
    pacman --noconfirm -D --asdeps "$pkg" || true
done

pacman -Qtdq | pacman --noconfirm -Rs - || true
pacman -Syu --needed "${packages_to_install[@]}"
pacman -S --needed --asdeps "${packages_to_install_optdeps[@]}"
pacman -D --asdeps "${packages_to_install_optdeps[@]}"

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

# Enable selected services
systemctl enable "${services[@]}"
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

# UKI installation
install -pm644 "${DIR}/etc/kernel/install.conf" /etc/kernel/install.conf

# Configure mkinitcpio
install -m755 -d /etc/mkinitcpio.conf.d/
install -m644 -t /etc/mkinitcpio.conf.d/ \
    "${DIR}/etc/mkinitcpio.conf.d/10-swsnr-systemd-base.conf" \
    "${DIR}/etc/mkinitcpio.conf.d/20-swsnr-coretemp.conf"

#region Nvidia special cases
if [[ "${use_nvidia}" == true ]]; then
    # For nvidia early-kms setup is more intricate because the standard kms hook
    # doesn't really seem to support it, so remove the KMS hook and use a more
    # elaborate nvidia configuration instead.
    install -m644 -t /etc/mkinitcpio.conf.d/ "${DIR}/etc/mkinitcpio.conf.d/20-swsnr-nvidia.conf"
    rm -f /etc/mkinitcpio.conf.d/20-swsnr-kms.conf

    # Enable modesetting
    install -m644 -t /etc/cmdline.d/ "${DIR}"/etc/cmdline.d/30-nvidia-modeset.conf

    # Load nvidia powermanagement modules, and disable GDM's nvidia override
    # rules. This seems to be required to get GDM to accept older nvidia cards.
    # We do know better than GDM here, otherwise we'd not set "use_nividia" to
    # true for the relevant system.
    install -pm644 "${DIR}/etc/modprobe-nvidia-power-management.conf" \
        /etc/modprobe.d/nvidia-power-management.conf
    ln -sf /dev/null /etc/udev/rules.d/61-gdm.rules
else
    # Use standard KMS hook if we're not using the proprietary driver.
    install -m644 -t /etc/mkinitcpio.conf.d/ \
        "${DIR}/etc/mkinitcpio.conf.d/20-swsnr-kms.conf"
    # Remove all the nvidia stuff
    rm -f \
        /etc/cmdline.d/30-nvidia-modeset.conf \
        /etc/mkinitcpio.conf.d/20-swsnr-nvidia.conf \
        /etc/modprobe.d/nvidia-power-management.conf \
        /etc/udev/rules.d/61-gdm.rules
fi
#endregion

# Configure kernel cmdline for mkinitcpio
install -m755 -d /etc/cmdline.d
install -m644 -t /etc/cmdline.d \
    "${DIR}"/etc/cmdline.d/10-swsnr-plymouth.conf \
    "${DIR}"/etc/cmdline.d/10-swsnr-quiet-boot.conf \
    "${DIR}"/etc/cmdline.d/20-swsnr-disable-zswap.conf \
    "${DIR}"/etc/cmdline.d/20-swsnr-rootflags-btrfs.conf
if [[ "${discover_rootfs}" == true ]]; then
    rm -f /etc/cmdline.d/30-explicit-root.conf
else
    install -m644 -t /etc/cmdline.d/ \
        "${DIR}"/etc/cmdline.d/30-explicit-root.conf
fi

# Boot loader configuration
case "${HOSTNAME}" in
*kastl*)
    # Use zen, as it's supposedly a better kernel for gaming
    install -pm644 "${DIR}/etc/loader-default-zen.conf" /efi/loader/loader.conf
    ;;
*)
    # Otherwise use stock kernel for maximum compatibility
    install -pm644 "${DIR}/etc/loader-default-arch.conf" /efi/loader/loader.conf
    ;;
esac

# System configuration
install -pm644 "${DIR}/etc/faillock.conf" /etc/security/faillock.conf
install -pm644 "${DIR}/etc/sysctl-swsnr.conf" /etc/sysctl.d/90-swsnr.conf
install -pm644 "${DIR}/etc/modprobe-swsnr.conf" /etc/modprobe.d/modprobe-swsnr.conf
install -pm644 "${DIR}/etc/modules-load-swsnr.conf" /etc/modules-load.d/swsnr.conf
install -D -m644 "${DIR}/etc/systemd/system/btrfs-scrub-io.conf" \
    "/etc/systemd/system/btrfs-scrub@.service.d/swsnr-limit-io.conf"
install -D -m644 "${DIR}/etc/plymouthd.conf" /etc/plymouth/plymouthd.conf

# Remove apparmor configuration
rm -rf /etc/cmdline.d/20-swsnr-lsm-apparmor.conf \
    /etc/apparmor.d/tunables/xdg-user-dirs.d/de

# sudo configuration
install -dm750 /etc/sudoers.d/
install -pm600 -t/etc/sudoers.d "${DIR}"/etc/sudoers.d/*

# Systemd configuration
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
install -Dpm644 "${DIR}/etc/systemd/system-swsnr.conf" /etc/systemd/system.conf.d/50-swsnr.conf
install -Dpm644 "${DIR}/etc/systemd/timesyncd-swsnr.conf" /etc/systemd/timesyncd.conf.d/50-swsnr.conf
install -Dpm644 "${DIR}/etc/systemd/resolved-swsnr.conf" /etc/systemd/resolved.conf.d/50-swsnr.conf
install -Dpm644 "${DIR}/etc/systemd/zram-generator.conf" /etc/systemd/zram-generator.conf
install -Dpm644 "${DIR}/etc/systemd/oomd-swsnr.conf" /etc/systemd/oomd.conf.d/50-swsnr.conf
install -Dpm644 "${DIR}/etc/systemd/root-slice-oomd-swsnr.conf" /etc/systemd/system/-.slice.d/50-oomd-swsnr.conf
install -Dpm644 "${DIR}/etc/systemd/user-service-oomd-swsnr.conf" /etc/systemd/system/user@.service.d/50-oomd-swsnr.conf

# Remove audit setup
rm -rf /etc/audit/rules.d/00-swsnr.rules /etc/cmdline.d/20-swsnr-audit.conf

# Services configuration
install -Dpm644 "${DIR}/etc/networkmanager-mdns.conf" /etc/NetworkManager/conf.d/50-mdns.conf

# Global font configuration
for file in 10-hinting-slight 10-sub-pixel-rgb 11-lcdfilter-default; do
    ln -sf "/usr/share/fontconfig/conf.avail/${file}.conf" "/etc/fonts/conf.d/${file}.conf"
done

# Locale settings
localectl set-locale de_DE.UTF-8
# --no-convert stops localectl from trying to apply the text console layout to
# X11/Wayland and vice versa
localectl set-keymap --no-convert us
localectl set-x11-keymap --no-convert us,de pc105 '' ,compose:ralt

# GDM dconf profile, for global GDM configuration, see
# https://help.gnome.org/admin/system-admin-guide/stable/login-banner.html.en
install -Dpm644 "${DIR}/etc/gdm-profile" /etc/dconf/profile/gdm

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
if command -v sbctl >/dev/null && [[ -f /usr/share/secureboot/keys/db/db.key ]]; then
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
    install -m644 "${DIR}/etc/fwupd-uefi_capsule_secure_boot.conf" \
        /etc/fwupd/uefi_capsule.conf

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
