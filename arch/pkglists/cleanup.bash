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

# List of packages to remove

packages=(
    # Tooling to build PKGBUILDs. I've moved my custom packages to OBS and no
    # longer build locally.
    base-devel
    aurutils
    devtools
    # Dev tooling I don't need currently
    gobject-introspection
    flatpak-builder
    zbus_xmlgen
    stylua
    # No longer need these
    innoextract
    rio
    pacman-hook-reproducible-status
    pacman-hook-kernel-install
    reflector
    # Flatpak'ed
    paperwork
    tesseract
    tesseract-data-deu
    tesseract-data-deu_frak
    tesseract-data-eng
    zim
)
