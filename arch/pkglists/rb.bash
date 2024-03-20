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
    skopeo                           # Container registry tool
    sbt                              # Scala build tool
    ammonite                         # Scala repl
    glab                             # Gitlab CLI
    fnm                              # Fast node version manager
    gnome-search-providers-jetbrains # Jetbrains projects in search
    ansible                          # Infrastructure management
    hurl                             # HTTP testing

    # VPN
    networkmanager-vpnc
    networkmanager-openconnect

    # Security
    rage-encryption # Simple file encryption
    age-plugin-tpm  # Age/Rage plugin for TPM keys

    # Networking and debugging tools
    lftp          # Powerful FTP client
    websocat      # Debug websockets on the CLI
    lnav          # Log file analyzer
    wireshark-qt  # Network capturing GUI
    wireshark-cli # CLI interface to wireshark

    # Additional applications
    keepassxc     # Keepass
    evolution-ews # Exchange for evolution
)

optdeps=(
    # virtualbox: Kernel modules
    virtualbox-host-dkms
    # libproxy: Proxy autoconfiguration URLs, for Gnome and Glib
    pacrunner
    # aardvark: DNS support
    aardvark-dns
    # Qt: wayland support
    qt5-wayland
    qt6-wayland
)

flatpaks=(
    org.apache.directory.studio # LDAP browser
    com.microsoft.Edge          # For teams
    com.jgraph.drawio.desktop   # Diagrams
    org.libreoffice.LibreOffice # Office
    org.kde.okular              # More powerful PDF viewer
    org.ksnip.ksnip             # Screenshot annotation tool
)
