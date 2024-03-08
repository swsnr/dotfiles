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

# List of basic packages and applications

packages=(
    # Basic packages & system tools
    base
    dbus-broker # Explicity install dbus-broker to avoid prompt
    linux-firmware
    intel-ucode
    linux
    mkinitcpio # Generate initramfs and build UKI
    sudo
    zram-generator # swap on compressed RAM, mostly to support systemd-oomd
    systemd-ukify  # Build and inspect UKIs
    sbctl          # Manage secure boot binaries and sign binaries
    mkosi          # Generate system images
    plymouth       # Splash screen for boot

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
    pacman-contrib    # Extra tools for pacman
    etc-update        # Deal with pacdiff/pacsave files
    arch-repro-status # Manually check reproducibility of installed packages

    # Build arch packages
    namcap     # Lint arch packages
    debuginfod # Remote debug info
    # Minimal parts of base-devel I actually need for my local packages
    fakeroot

    # Shell environment and CLI tools
    helix             # Simple terminal editor with LSP support
    wezterm           # My preferred terminal emulator
    fish              # My preferred shell
    zoxide            # Cross-shell/editor directory jumping
    fzf               # Fuzzy file finder for shells
    man-db            # Man page reader
    man-pages         # Linux manpagers
    eza               # Better ls (with git support)
    broot             # Interactive tree & cd
    vivid             # Creates themes for dircolors
    ripgrep           # Better grep
    ripgrep-all       # ripgrep for all kinds of files
    bat               # Better less
    mdcat             # Cat markdown files
    fd                # Simpler find
    sd                # Simpler sed
    dua-cli           # Disk space analyzer
    nnn               # Command line file manager
    renameutils       # qmv is super nice
    restic            # Backups
    p7zip             # CLI zip file tool
    imagemagick       # Handy and powerful image processing tools
    inotify-tools     # Watch for file changes
    qrencode          # Quickly generate QR codes
    zbar              # Decode QR codes
    pandoc-cli-static # Convert markup formats and documents

    # Git and related tools
    git
    git-filter-repo
    git-lfs
    git-gone
    github-cli

    # Development tooling
    gcc                 # C compiler
    patch               # Apply patches
    make                # Ubiquituous "build" tool
    rustup              # Rust toolchain manager
    rust-analyzer       # Language server for Rust (more recent than what's provided by rustup)
    cargo-release       # Rust release helper
    cargo-semver-checks # Lint public Rust APIs
    cargo-deny          # Rust compliance checker (licensing, advisories, etc.)
    shellcheck-static   # Lint bash code
    shfmt               # Format bash code
    ruff                # Fast python linter
    pyright             # Language server for Python
    hexyl               # hex viewer
    oxipng              # Optimize PNGs for size
    jq                  # Process JSON on command line
    d-spy               # DBus inspector and debugger
    deno                # Typescript runtime, for scripting
    osc                 # Client for Opensuse build service

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

optdeps=(
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

    # udisks2: btrfs support
    udisks2-btrfs
)

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
