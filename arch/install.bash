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

PS4='\033[32m$(date +%H:%M:%S) >>>\033[0m '

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

function add_tree() {
    local tree="$1"
    cp --recursive --no-dereference --preserve=links,mode,timestamps \
        --target-directory=/ --update --verbose \
        "${DIR}/trees/${tree}/."
}

function remove_tree() {
    local tree="$1"
    find "${DIR}/trees/${tree}" '!' -type d \
        -exec realpath --no-symlinks --relative-base="${DIR}/trees/${tree}" {} \; |
        xargs -n1 printf "/%s\0" | xargs -0 rm -vfd
}

#region Configuration
# Whether to upgrade packages.  Set to false to avoid an initial pacman -Syu
upgrade_packages=true

# By default, do not use the proprietary nvidia driver
use_nvidia=false

# Configure secureboot if secureboot keys exist
use_secureboot=false
if command -v sbctl >/dev/null && [[ -f /usr/share/secureboot/keys/db/db.key ]]; then
    use_secureboot=true
fi
#endregion

#region Basic packages and services
# Packages to remove with --cascade set, to clean up entire package hierarchies, e.g. when switching desktops
packages_to_remove_cascade=()

# Packages to remove
packages_to_remove=(
    # Dev tooling I don't need currently
    gobject-introspection
    flatpak-builder
    zbus_xmlgen
    stylua
    # No longer need these
    innoextract
    rio
    # Flatpak'ed
    paperwork
    tesseract
    tesseract-data-deu
    tesseract-data-deu_frak
    tesseract-data-eng
    zim
)

# Packages to mark as optional dependencies
packages_to_mark_as_deps=()

packages_to_install=(
    # Basic packages & system tools
    base
    dbus-broker # Explicity install dbus-broker to avoid prompt
    linux-firmware
    intel-ucode
    linux
    mkinitcpio # Generate initramfs and build UKI
    sudo
    pacman-hook-kernel-install # Install kernels to /efi
    zram-generator             # swap on compressed RAM, mostly to support systemd-oomd
    systemd-ukify              # Build UKIs (see kernel/install.conf)
    sbctl                      # Manage secure boot binaries and sign binaries
    mkosi                      # Generate system images
    plymouth                   # Splash screen for boot

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
    iotop         # Monitor IO load
    htop          # Monitor processes
    bottom        # Overall system monitor
    lsof          # Check open files
    smartmontools # Disk monitoring

    # Networking & security
    networkmanager       # Standard desktop network tool
    nm-connection-editor # Advanced connection settings for network manager
    firewalld            # Firewall
    avahi                # DNS-SD for CUPS, only for service-discovery (name resolution is done by resolved)
    sequoia-sq           # Sane GPG tooling
    acme.sh              # ACME/Letsencrypt client
    xh                   # HTTP requests on the command line
    rsync                # Remote copy and syncing
    rclone               # rsync for clouds
    yt-dlp               # youtube-dl with extra features
    wol                  # Wake up systems on LAN
    nmap                 # Port scanning and other network information

    # Arch tools
    etc-update                      # Deal with pacdiff/pacsave files
    reflector                       # Keep mirror list updated
    arch-repro-status               # Manually check reproducibility of installed packages
    pacman-hook-reproducible-status # Check reproducibility of packages in pacman transactions

    # Build arch packages
    base-devel
    namcap     # Lint arch packages
    devtools   # Build arch packages (pkgctl mainly)
    debuginfod # Remote debug info
    aurutils   # Tooling for AUR packages

    # Shell environment and CLI tools
    helix         # Simple terminal editor with LSP support
    wezterm       # My preferred terminal emulator
    fish          # My preferred shell
    zoxide        # Cross-shell/editor directory jumping
    fzf           # Fuzzy file finder for shells
    man-db        # Man page reader
    man-pages     # Linux manpagers
    eza           # Better ls (with git support)
    broot         # Interactive tree & cd
    vivid         # Creates themes for dircolors
    ripgrep       # Better grep
    ripgrep-all   # ripgrep for all kinds of files
    bat           # Better less
    mdcat         # Cat markdown files
    fd            # Simpler find
    sd            # Simpler sed
    dua-cli       # Disk space analyzer
    nnn           # Command line file manager (also a good pager for aurutils)
    renameutils   # qmv is super nice
    restic        # Backups
    p7zip         # CLI zip file tool
    imagemagick   # Handy and powerful image processing tools
    inotify-tools # Watch for file changes
    qrencode      # Quickly generate QR codes
    zbar          # Decode QR codes

    # Git and related tools
    git
    git-filter-repo
    git-lfs
    git-gone
    github-cli

    # Development tooling
    gcc                 # C compiler
    make                # Ubiquituous "build" tool
    rustup              # Rust toolchain manager
    rust-analyzer       # Language server for Rust (more recent than what's provided by rustup)
    cargo-release       # Rust release helper
    cargo-semver-checks # Lint public Rust APIs
    cargo-deny          # Rust compliance checker (licensing, advisories, etc.)
    shellcheck          # Lint bash code
    shfmt               # Format bash code
    ruff                # Fast python linter
    pyright             # Language server for Python
    hexyl               # hex viewer
    oxipng              # Optimize PNGs for size
    jq                  # Process JSON on command line
    d-spy               # DBus inspector and debugger
    deno                # Typescript runtime, for scripting

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
    evolution               # Mail client & calendar (even on KDE, because kmail and korganizer have a bunch of issues
    code                    # Powerful text editor, i.e. poor-mans IDE

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
    ttf-ibm-plex       # A nice set of fonts from IBM
    inter-font         # A good user interface font
)

packages_to_install_optdeps=(
    # vulkan-icd-loader: vulkan driver
    vulkan-intel
    # linux: wireless frequency policies (provided as crda)
    wireless-regdb
    # libva: intel drivers
    intel-media-driver

    # Mark pipewire as optional dependencies
    pipewire-pulse wireplumber
    # pipewire: zeroconf support
    pipewire-zeroconf

    # poppler: data files
    poppler-data

    # enchant: fast and modern spell checking backend
    nuspell

    # mkosi: cpio format
    cpio
)

# Flatpaks
flatpaks=(
    com.usebottles.bottles # Windows software, mostly gaming

    # Misc tools
    org.gnome.clocks           # Word clock
    org.gnome.Maps             # Simple maps application
    org.gnome.Characters       # Character chooser
    org.gnome.Weather          # Weather app
    com.belmoussaoui.Obfuscate # Obfuscate things in screenshots
    com.github.tchx84.Flatseal # Manage flatpak permissions
    de.schmidhuberj.DieBahn    # Public transit client
    io.github.Qalculate        # Scientific desktop calculator w/ unit conversion and search provider
    org.remmina.Remmina        # Remote access

    # Knowledge management
    org.jabref.jabref # Library & reference manager
    com.logseq.Logseq # Knowledge management and journal
    com.zettlr.Zettlr # Markdown editor with Zettelkasten features
    org.zim_wiki.Zim  # To access old zim wikis

    # Documents
    org.cvfosammmm.Setzer  # GNOME LaTeX editor
    com.github.ahrm.sioyek # PDF viewer for papers and real documents

    # Messaging
    org.gnome.Fractal # Simple matrix client
    org.signal.Signal # Messaging

    # Social media
    dev.geopjr.Tuba # Mastodon client

    # Multimedia
    org.videolan.VLC            # Powerful video player
    org.atheme.audacious        # Lightweight audio player
    com.github.wwmm.easyeffects # Audio effects for pipewire
)

flatpaks_to_remove=()

trees_to_add=(base)
trees_to_remove=()

files_to_remove=()
#endregion

#region GNOME desktop
packages_to_install+=(
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
    gnome-keyring
    gnome-shell
    gnome-shell-extensions # Built-in shell extensions for Gnome
    gnome-disk-utility
    gnome-system-monitor
    gnome-control-center
    gnome-tweaks
    gnome-backgrounds
    gnome-themes-extra # Adwaita dark, for dark mode in Gtk3 applications
    gnome-terminal     # Backup terminal, in case I mess up wezterm
    yelp               # Manual viewer for GNOME applications
    nautilus           # File manager
    sushi              # Previewer for nautilus
    evince             # Document viewer
    loupe              # Image viewer
    simple-scan        # Scanning
    seahorse           # Gnome keyring manager
    gnome-firmware     # Manage firmware with Gnome

    # Gnome extensions and tools
    gnome-shell-extension-appindicator              # Systray for Gnome
    gnome-shell-extension-caffeine                  # Inhibit suspend
    gnome-shell-extension-disable-extension-updates # Don't check for extension updates
    gnome-shell-extension-picture-of-the-day        # Picture of the day as background
    gnome-shell-extension-utc-clock                 # UTC clock for the panel
    gnome-search-providers-vscode                   # VSCode workspaces in search
)

packages_to_install_optdeps+=(
    # gnome-shell: screen recording support
    gst-plugins-good
    gst-plugin-pipewire

    # gnome-control-center: app permissions
    malcontent

    # nautilus: search
    tracker3-miners

    # wezterm: Nautilus integration
    # gnome-shell-extension-gsconnect: Send to menu
    python-nautilus
    # wezterm: Fallback font for symbols
    ttf-nerd-fonts-symbols-mono
)
#endregion

#region Per-host and per-hardware packages, services, etc.
case "${PRODUCT_NAME}" in
'XPS 9315')
    packages_to_install+=(
        sof-firmware # Firmware for XPS audio devices
        thermald     # Thermal management for intel systems
    )

    trees_to_add+=("intel")
    ;;
*) ;;
esac

case "${HOSTNAME}" in
*kastl*)
    pacman_repositories+=()

    packages_to_install+=(
        # Ruby
        ruby-install

        # GNOME development tooling
        blueprint-compiler # UI language compiler

        # Game mode
        gamemode
        scummvm # For the classics

        # Apps
        gnucash # Finance manager

        gnome-shell-extension-gsconnect # Connect phone and desktop system
        syncthing                       # Network synchronization
    )

    packages_to_install_optdeps+=(
        # sdl2: Wayland client decorations
        libdecor
    )

    flatpaks+=(
        # Gaming; we're using flatpak for these because otherwise we'd have to
        # cope with multilib and mess around with missing steam dependencies.
        com.valvesoftware.Steam
        io.github.ja2_stracciatella.JA2-Stracciatella # JA2 for this century

        # Gtk tooling
        re.sonny.Workbench           # Playround for Gtk things
        app.drey.Biblioteca          # Doc browser for Gtk
        net.poedit.Poedit            # Translation edit
        org.gnome.design.IconLibrary # Icons for GNOME apps

        # Applications
        de.bund.ausweisapp.ausweisapp2        # eID
        re.chiaki.Chiaki                      # Remote play client for playstation
        ch.threema.threema-web-desktop        # Chat
        com.github.eneshecan.WhatsAppForLinux # Another chat
        de.mediathekview.MediathekView        # Client for German TV broadcasting stations
        org.kde.tellico                       # Manage collections of books, etc.
        org.kde.digikam                       # Digital photo management
        io.freetubeapp.FreeTube               # Ad-free youtube client
        work.openpaper.Paperwork              # Manage personal documents
    )
    ;;
*RB*)
    packages_to_install+=(
        linux-lts # Fallback kernel

        # Kernel headers for DKMS
        linux-headers
        linux-lts-headers

        # Virtualisation
        virtualbox-host-dkms
        virtualbox-guest-iso
        virtualbox

        dotnet-sdk                       # .NET development
        podman                           # Deamonless containers
        podman-docker                    # Let's be compatible
        docker-compose                   # Manage multiple containers for development
        kubectl                          # k8s client
        kubeconform                      # Validate kubernetes manifests
        k9s                              # k8s TUI
        helm                             # k8s package manager
        skopeo                           # Container registory tool
        sbt                              # Scala build tool
        ammonite                         # Scala repl
        glab                             # Gitlab CLI
        fnm                              # Fast node version manager
        gnome-search-providers-jetbrains # Jetbrains projects in search
        ansible                          # Infrastructure management

        # VPN
        networkmanager-vpnc
        networkmanager-openconnect

        # Security
        rage-encryption # Simple file encryption
        age-plugin-tpm  # Age/Rage plugin for TPM keys

        # Networking and debugging tools
        lftp     # Powerful FTP client
        websocat # Debug websockets on the CLI
        lnav     # Log file analyzer

        # Additional applications
        keepassxc     # Keepass
        evolution-ews # Exchange for evolution
    )

    packages_to_install_optdeps+=(
        # virtualbox: Kernel modules
        virtualbox-host-dkms
        # libproxy: Proxy autoconfiguration URLs, for Gnome and Glib
        pacrunner
        # aardvark: DNS support
        aardvark-dns
        # Qt: wayland support
        qt5-wayland
    )

    flatpaks+=(
        org.apache.directory.studio # LDAP browser
        com.microsoft.Edge          # For teams
        com.jgraph.drawio.desktop   # Diagrams
        org.libreoffice.LibreOffice # Office
        org.kde.okular              # More powerful PDF viewer
        org.ksnip.ksnip             # Screenshot annotation tool
    )

    trees_to_add+=("rb")
    ;;
*) ;;
esac
#endregion

# Setup proprietary nvidia driver if enabled
if [[ "${use_nvidia}" == true ]]; then
    packages+=(
        nvidia
        nvidia-lts
    )

    trees_to_remove+=("kms")
    trees_to_add+=("nvidia")
else
    packages_to_remove+=(
        nvidia
        nvidia-lts
    )

    trees_to_remove+=("nvidia")
    trees_to_add+=("kms")
fi

# Configure secure boot if enabled
if [[ "${use_secureboot}" == true ]]; then
    trees_to_add+=(secureboot)
else
    trees_to_remove+=(secureboot)
fi

# Cleanup files
if [[ 0 -lt ${#files_to_remove[@]} ]]; then
    rm -rf "${files_to_remove[@]}"
fi

# Add our filesystem trees
for tree in "${trees_to_add[@]}"; do
    echo "Adding filesystem tree ${tree}"
    add_tree "${tree}"
done

for tree in "${trees_to_remove[@]}"; do
    echo "Removing filesystem tree ${tree}"
    remove_tree "${tree}"
done

# Correct permissions
chmod 750 /etc/sudoers.d
find /etc/sudoers.d -type f -exec chmod 600 {} \+

# Import our signing key into pacman's keyring
pacman-key -a "${DIR}/pacman-signing-key.asc"
pacman-key --lsign-key B8ADA38BC94C48C4E7AABE4F7548C2CC396B57FC

#region Package installation and service setup
# Remove packages one by one because pacman doesn't handle uninstalled packages
# gracefully
for pkg in "${packages_to_remove_cascade[@]}"; do
    if pacman -Qi "${pkg}" &>/dev/null; then
        pacman --noconfirm -Rsc "${pkg}" || true
    fi
done

for pkg in "${packages_to_remove[@]}"; do
    if pacman -Qi "${pkg}" &>/dev/null; then
        pacman --noconfirm -Rs "${pkg}"
    fi
done

# Mark packages as optional dependencies one by one, because pacman doesn't
# handle missing packages gracefully here.
for pkg in "${packages_to_mark_as_deps[@]}"; do
    if pacman -Qi "${pkg}" &>/dev/null; then
        pacman --noconfirm -D --asdeps "${pkg}" || true
    fi
done

# Update mirror list before installing anything; we use the systemd service
# because it uses the appropriate reflector configuration.
if command -v reflector >/dev/null && [[ -e /etc/xdg/reflector/reflector.conf ]]; then
    systemctl start reflector.service || true
fi

pacman -Qtdq | pacman --noconfirm -Rs - || true
# Update the system, then install new packages and optional dependencies.
if [[ "${upgrade_packages}" == "true" ]]; then
    pacman -Syu
fi
pacman -S --needed "${packages_to_install[@]}"
pacman -S --needed --asdeps "${packages_to_install_optdeps[@]}"
pacman -D --asdeps "${packages_to_install_optdeps[@]}"

# Remove unused local pacman repos
for name in abs aur; do
    if [[ -d "/srv/pkgrepo/${name}" ]]; then
        btrfs subvolume delete "/srv/pkgrepo/${name}"
    fi
done

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

# Update systemd preset to enable/disable services
systemctl preset-all

if [[ -n "${MY_USER_ACCOUNT}" ]]; then
    # Scrub home directory of my user account
    # TODO: Move this to a generated preset file
    instance="$(systemd-escape -p "/home/${MY_USER_ACCOUNT}")"
    systemctl enable "btrfs-scrub@${instance}.timer"
fi

# Mask a few services I don't want
systemctl mask passim.service # Caching daemon from fwupd

# Locale settings
localectl set-locale de_DE.UTF-8
# --no-convert stops localectl from trying to apply the text console layout to
# X11/Wayland and vice versa
localectl set-keymap --no-convert us
localectl set-x11-keymap --no-convert us,de pc105 '' ,compose:ralt

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
if [[ "${use_secureboot}" == true ]]; then
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
