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
    echo "Run this as regular user"
    exit 1
fi

if [[ "${HOSTNAME}" != *kastl ]]; then
    echo "This is not a kastl host"
    exit 1
fi

flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrep

# Install some personal flatpaks
flatpaks=(
    com.skype.Client # Sadly necessary
    org.jitsi.jitsi-meet # Secure video chats
    com.github.geigi.cozy # Audiobook player
    org.gnucash.GnuCash # Personal finances
    org.kde.digikam # Photo collection
    re.chiaki.Chiaki # PSN remote play client
    com.valvesoftware.Steam # Gaming
    de.bund.ausweisapp.ausweisapp2 # e-ID
)

flatpak install --system --or-update --noninteractive "${flatpaks[@]}"
