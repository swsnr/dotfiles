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

# Install a GRML

set -xeuo pipefail

BOOTPATH="$(bootctl -x)"

if ! mountpoint -q "$BOOTPATH"; then
    echo "Extended boot not mounted at $BOOTPATH" 1>&2
    exit 1
fi

if [[ $EUID != 0 ]]; then
    echo 'Elevating privileges'
    exec sudo "$0" "$@"
fi

dir="$( cd "$( dirname "${BASH_SOURCE[0]}")"  >/dev/null 2>&1 && pwd)"

desired_version="2020.06"
installed_version="$(grep -E '^version' "$BOOTPATH/loader/entries/grml.conf" | cut -d' ' -f2 || true)"

if [[ $desired_version == "${installed_version:-}" ]]; then
    echo "Already installed"
    exit 0
fi

iso="grml64-small_${desired_version}.iso"
mirror="https://ftp.halifax.rwth-aachen.de//grml/"

download_dir="$(mktemp --directory --tmpdir=/var/tmp grml-rescue.XXXXXX)"
trap '{ rm -rf -- "$download_dir"; }' EXIT

curl -Lf   --tlsv1.2 --proto '=https' -o "${download_dir}/${iso}"     "${mirror}/${iso}"
curl -LsSf --tlsv1.2 --proto '=https' -o "${download_dir}/${iso}.asc" "${mirror}/${iso}.asc"
gpgv --keyring "$dir/grml-trustdb.gpg" "${download_dir}/${iso}.asc" "${download_dir}/${iso}"

relevant_files=(
    live/grml64-small/grml64-small.squashfs
    boot/grml64small/vmlinuz
    boot/grml64small/initrd.img
)
7z e -o"${download_dir}" "${download_dir}/${iso}" -- "${relevant_files[@]}"

# Install the squashed filesystem
install -pm600 -D -t "$BOOTPATH/grml" \
    "${download_dir}/grml64-small.squashfs" \
    "${download_dir}/vmlinuz" \
    "${download_dir}/initrd.img"

# Create a standard type #1 boot loader entry for systemd-boot
mkdir -p "$BOOTPATH/loader/entries"

cat >"$BOOTPATH/loader/entries/grml.conf" <<EOF
title   Grml Live Linux
version ${desired_version}
linux   /grml/vmlinuz
initrd  /grml/initrd.img
options lang=us utc tz=Europe/Berlin boot=live live-media-path=/grml/
EOF
