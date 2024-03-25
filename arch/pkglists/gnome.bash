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

# Gnome packages and applications

packages=(
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

optdeps=(
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

    # gnome-shell: Support for captive portals, see
    # https://gitlab.archlinux.org/archlinux/packaging/packages/gnome-shell/-/issues/5
    webkitgtk-6.0
)
