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

## Apps via flatpaks

if [[ $EUID -eq 0 ]]; then
    echo "Install flatpaks as user"
    exit 1
fi

flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrep

common_flatpaks=(
    com.github.tchx84.Flatsecal # Manage flatpak permissions
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

flatpak install --user --or-update --noninteractive "${common_flatpaks[@]}"

if [[ "${HOSTNAME}" == *kastl ]]; then
    # Install some personal flatpaks
    personal_flatpaks=(
        com.skype.Client # Sadly necessary
        org.jitsi.jitsi-meet # Secure video chats
        org.gnome.Lollypop # Music manager
        com.github.geigi.cozy # Audiobook player
        org.gnucash.GnuCash # Personal finances
        org.kde.digikam # Photo collection
        re.chiaki.Chiaki # PSN remote play client
        com.valvesoftware.Steam # Gaming
    )

    flatpak install --user --or-update --noninteractive "${personal_flatpaks[@]}"
fi
