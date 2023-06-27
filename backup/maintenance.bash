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

INHIBITOR_APP_ID=""

if [[ -n ${GNOME_TERMINAL_SERVICE:-} ]]; then
    INHIBITOR_APP_ID=org.gnome.Terminal.desktop
elif [[ ${TERM_PROGRAM:-} == "WezTerm" ]]; then
    INHIBITOR_APP_ID=org.wezfurlong.wezterm.desktop
fi

if [[ -z "${INHIBITOR_APP_ID}" ]]; then
    echo 'Cannot determine terminal App to inhibit logout during backup'
    exit 1
fi

inhibit() {
    local reason
    reason="$1"
    shift
    # See backup.bash about why we have to use gnome-session-inhibit with an
    # actual application.
    gnome-session-inhibit \
        --app-id "${INHIBITOR_APP_ID}" --reason "${reason}" \
        --inhibit "logout:suspend" \
        "$@"
}

USERNAME="$(id -un)"

# Cleanup snapshots made by the dotfiles script:  Definitely keep the last ten
# snapshots, and# everything within the last six months.  For the last two years
# keep montly snapshots, and keep a yearly snapshot for like forever.
inhibit "Deleting old backup snapshots" \
    restic -r "rclone:kastl:restic-${USERNAME}" forget \
    --prune \
    --tag basti,dotfiles-script \
    --keep-last 10 \
    --keep-within 6m \
    --keep-monthly 24 \
    --keep-yearly 20
inhibit "Removing old data" restic -r "rclone:kastl:restic-${USERNAME}" prune
# Check that the data is still valid
inhibit "Verifying backups" \
    nice restic -r "rclone:kastl:restic-${USERNAME}" check --read-data-subset '10%'
