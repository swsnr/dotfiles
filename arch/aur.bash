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

GPGKEY="B8ADA38BC94C48C4E7AABE4F7548C2CC396B57FC"
export GPGKEY

REPODB="/srv/pkgrepo/aur/aur.db.tar.zst"
REPODIR="${REPODB%/*}"
REPONAME="${REPODB##*/}"
REPONAME="${REPONAME%%.*}"

packages=(
    # AUR helper
    aurutils

    # Early boot and kernels
    pacman-hook-kernel-install
    plymouth # Splash screen at boot

    # Hardware support
    pcsc-cyberjack # Card reader driver for eID

    # Gnome extensions and tools
    gnome-shell-extension-nasa-apod       # APOD as desktop background
    gnome-shell-extension-burn-my-windows # Old school window effects
    gnome-shell-extension-desktop-cube    # The old school desktop cube effect
    gnome-shell-extension-fly-pie         # Touchscreen and mouse launcher
    gnome-search-providers-jetbrains      # Jetbrains projects in search
    gnome-search-providers-vscode         # VSCode workspaces in search
    firefox-gnome-search-provider         # Firefox bookmarks in search

    # Applications
    1password 1password-cli # Personal password manager
    jabref                  # Bibliography
    setzer                  # Simple and easy latex editor

    # Additional fonts
    otf-vollkorn # My favorite serif font for documents
    ttf-fira-go  # A nice font for presentations

    # Additional tools
    git-gone # Prune gone branches
    wcal-git # ISO week calender on CLI
    wev      # Wayland event testing
    frum     # Ruby version manager
    fnm      # Node version manager

    # Missing dependencies for latexindent
    # See <https://bugs.archlinux.org/task/60210>
    texlive-latexindent-meta
)

case "$HOSTNAME" in
*kastl*)
    packages+=(
        gnome-shell-extension-gsconnect # Connect phone and desktop system

        # Applications
        ausweisapp2        # eID app
        chiaki-git         # Remote play client for PS4/5; use git for better controller support
        whatsapp-for-linux # Whatsapp desktop client for Linux
        ja2-stracciatella  # Modern runtime for the venerable JA2
        cozy-audiobooks    # Audiobook manager
        threema-desktop    # Secure messaging

        # sdl support tools
        controllermap
        sdl2-jstest
    )
    ;;
*RB*)
    packages+=(
        # The legacy
        python2
    )
    ;;
esac

bootstrap-aurutils() {
    # Run everything in a subshell to isolate cd and remove the tempdir as early
    # as possible.
    (
        BDIR="$(mktemp -d --tmpdir aurutils.XXXXXXXX)"
        # Deliberately expand here to propagate the path to the trap handler
        # shellcheck disable=SC2064
        trap "rm -rf '$BDIR'" EXIT
        echo "Building aurutils in $BDIR"
        cd "$BDIR"
        git clone --depth=1 "https://aur.archlinux.org/aurutils.git"
        cd aurutils
        makepkg --noconfirm --nocheck -rsi --sign
    )
}

# This is run in a separate shell through sudo to create the subvolume for the
# repo
create-repository-subvolume() {
    set -xeuo pipefail
    local dir
    dir="$1"
    install -m755 -d /srv/pkgrepo
    btrfs subvolumne create "$dir"
    chown -R "${SUDO_UID}:$(id -g "$SUDO_UID")" "$dir"
}

remove-pkg() {
    local pkg
    pkg="$1"
    # FIXME: This removes too much perhaps?
    rm -f "${REPODIR}/${pkg}-"*.pkg.tar.*
    repo-remove --sign --key "${GPGKEY}" "$REPODB" "$pkg"
}

bootstrap() {
    if ! command -v aur &>/dev/null; then
        bootstrap-aurutils
    fi

    if [[ ! -e "$REPODB" ]]; then
        sudo bash -c "$(declare -f create-repository-subvolume); create-repository-subvolume '$REPODIR'"
        repo-add --sign --key "$GPGKEY" "$REPODB"
    fi
}

backup() {
    # Backup built packages for faster reinstallation
    restic -r "rclone:kastl:restic-$USERNAME" backup "$REPODIR" \
        --tag kastl-aur-repo --exclude-caches
    # And discard old snapshots for the repodir (be careful to select only the
    # repo dir and the corresponding tag to avoid pruning other backup snapshots
    # in the repo so aggressively)
    restic -r "rclone:kastl:restic-$USERNAME" forget \
        --keep-last 3 --path "$REPODIR" --tag kastl-aur-repo
}

collect-dependencies() {
    local -n __depends="$1"
    shift
    # shellcheck disable=SC2034
    readarray -t __depends < <(aur depends "$@")
}

collect-debug-packages() {
    local -n __debug="$1"
    shift
    # shellcheck disable=SC2034
    __debug=("${@/%/-debug}")
}

collect-packages-to-remove() {
    local -n __to_remove="$1"
    shift

    local packages_in_repo

    readarray -t packages_in_repo < <(aur repo -d "$REPONAME" -lq)
    readarray -t __to_remove < <(printf "%s\n" "$@" "${packages_in_repo[@]}" | sort | uniq -u)
    # shellcheck disable=SC2034
    readarray -t __to_remove < <(printf "%s\n" "${packages_in_repo[@]}" "${__to_remove[@]}" | sort | uniq -d)
}

remove-except() {
    local remove_from_repo
    collect-packages-to-remove remove_from_repo "$@"
    if [[ ${#remove_from_repo[@]} -gt 0 ]]; then
        for pkg in "${remove_from_repo[@]}"; do
            remove-pkg "$pkg"
        done
    fi
}

main() {
    bootstrap

    local packages_with_dependencies
    local packages_with_dependencies_and_debug
    local remove_from_repo

    collect-dependencies packages_with_dependencies "${packages[@]}"

    # Remove packages we no longer need; we do also retain all possible debug
    # packages.
    collect-debug-packages packages_with_dependencies_and_debug "${packages_with_dependencies[@]}"
    packages_with_dependencies_and_debug+=("${packages_with_dependencies[@]}")
    remove-except "${packages_with_dependencies_and_debug[@]}"

    aur sync -daur --nocheck -cRS "${packages[@]}"

    # On my personal systems backup repo to my personal NAS to allow reinstalling
    # without rebuilding everything
    if [[ "$HOSTNAME" == *kastl* ]] && resolvectl query kastl.local &>/dev/null; then
        backup
    fi
}

if [[ "$0" == "${BASH_SOURCE[0]}" || -z "${BASH_SOURCE[0]}" ]]; then
    # Run only if not sourced; this lets me interactively work with the package
    # list above
    set -xeuo pipefail
    main
fi
