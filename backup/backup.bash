#!/bin/bash
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

set -xeuo pipefail

USERNAME="$(id -un)"

inhibit() {
    case "${XDG_CURRENT_DESKTOP:-}" in
    KDE)
        kde-inhibit --power "${@}"
        ;;
    GNOME)
        # Inhibit logout (which includes shutdown) and suspend in the name of the
        # running terminal emulator, to make sure the backup completes without
        # interruptions.
        #
        # We need to use gnome-session-inhibit and an existing app ID to make the
        # inhibitor appear in the logout dialog; Gnome session logout doesn't show
        # systemd inhibitors and it doesn't show inhibitors without app IDs, because no
        # icon I guess.  See https://discourse.gnome.org/t/gnome-logout-dialog-ignores-inhibitors/8602/4
        # for details; not the most useful behaviour in my opinion, but it's not a fight
        # for me to pick.
        INHIBITOR_APP_ID=""

        if [[ -n "${GNOME_TERMINAL_SERVICE:-}" ]]; then
            INHIBITOR_APP_ID=org.gnome.Terminal.desktop
        elif [[ "${TERM_PROGRAM:-}" == "kgx" ]]; then
            INHIBITOR_APP_ID=org.gnome.Console.desktop
        elif [[ "${TERM_PROGRAM:-}" == "WezTerm" ]]; then
            INHIBITOR_APP_ID=org.wezfurlong.wezterm.desktop
        fi

        if [[ -z "${INHIBITOR_APP_ID}" ]]; then
            echo 'Cannot determine terminal App to inhibit logout during backup'
            exit 1
        fi

        exec gnome-session-inhibit \
            --app-id "${INHIBITOR_APP_ID}" --reason 'Ongoing backup' \
            --inhibit "logout:suspend" "${@}"
        ;;
    *)
        return 1
        ;;
    esac
}

inhibit \
    restic -r "rclone:kastl:restic-${USERNAME}" backup ~ \
    --one-file-system \
    --tag basti \
    --tag dotfiles-script \
    --exclude-caches \
    --exclude-file "${HOME}/.config/restic/linux.exclude" \
    --verbose \
    "$@"
