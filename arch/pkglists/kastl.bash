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

packages=(
    blueprint-compiler              # UI language compiler
    gamemode                        # Game mode
    gnome-shell-extension-gsconnect # Connect phone and desktop system
    syncthing                       # Network synchronization
)

optdeps=()

flatpaks=(
    # Gaming; we're using flatpak for these because otherwise we'd have to
    # cope with multilib and mess around with missing steam dependencies.
    com.valvesoftware.Steam
    io.github.ja2_stracciatella.JA2-Stracciatella # JA2 for this century
    org.scummvm.ScummVM                           # For classics

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
    org.gnome.Boxes                       # Easy to use VMs
    org.gnucash.GnuCash                   # Personal finances
)
