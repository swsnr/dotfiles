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

# Bootstrap a new Arch system from an installation ISO.

set -xeuo pipefail

PS4='\033[32m$(date +%H:%M:%S) >>>\033[0m '

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

target_device="$1"
encrypt="true"

if [[ -z "${target_device}" ]]; then
    echo "Missing --device <device> argument" >&2
    exit 2
fi

if [[ "${UID}" -ne 0 ]]; then
    echo "This script needs to be run as root!" >&2
    exit 3
fi

read -rp "THIS SCRIPT WILL OVERWRITE ALL CONTENTS OF ${target_device}. Type uppercase yes to continue: " confirmed

if [[ "${confirmed}" != "YES" ]]; then
    echo "aborted" >&2
    exit 128
fi

# Partition
sgdisk -Z "${target_device}"
sgdisk \
    -n1:0:+550M -t1:ef00 -c1:EFISYSTEM \
    -N2 -t2:8304 -c2:linux \
    "${target_device}"

# Reload partition table
sleep 3
partprobe -s "${target_device}"
sleep 3

root_device="/dev/disk/by-partlabel/linux"

if [[ "${encrypt}" == "true" ]]; then
    # Encrypt root if desired
    cryptsetup luksFormat --type luks2 "${root_device}"
    cryptsetup luksOpen "${root_device}" root
    # Enable discards and disable workqueues, see
    # https://wiki.archlinux.org/title/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD)
    # and
    # https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance
    cryptsetup refresh \
        --allow-discards \
        --perf-no_read_workqueue --perf-no_write_workqueue \
        --persistent \
        root
    root_device="/dev/mapper/root"
fi

# Create file systems
mkfs.fat -F32 -n EFISYSTEM /dev/disk/by-partlabel/EFISYSTEM
mkfs.btrfs -f -L linux "${root_device}"

SYSROOT="/mnt"

# Mount arch subvolume and create additional subvolumes for rootfs.  Enable
# compression for the bootstrap process.
mount -o 'compress=zstd:1' "${root_device}" "${SYSROOT}"
mkdir "${SYSROOT}"/efi
for subvol in var var/log var/cache var/tmp srv home; do
    btrfs subvolume create "${SYSROOT}/${subvol}"
done
# Disable CoW for /home due to large loopback files by systemd-homed
chattr +C "${SYSROOT}/home"

# Mount additional partitions
mount /dev/disk/by-partlabel/EFISYSTEM "${SYSROOT}/efi"

echo "Bootstrapping"
# Use the global pkgbuild mirror for simplicity
# shellcheck disable=SC2016
echo 'Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch' >/etc/pacman.d/mirrorlist
pacman -Sy archlinux-keyring
bootstrap_packages=(
    base
    linux
    linux-firmware
    intel-ucode
    btrfs-progs
    # Some essential tools: A text editor, network management, and restic to
    # restore backups (in particular my own package repository).
    helix
    networkmanager
    restic
)
pacstrap -K "${SYSROOT}" "${bootstrap_packages[@]}"

echo "Setting up locales"
sed -i \
    -e '/^#en_GB.UTF-8/s/^#//' \
    -e '/^#de_DE.UTF-8/s/^#//' \
    "${SYSROOT}"/etc/locale.gen
echo "Generating locales"
arch-chroot "${SYSROOT}" locale-gen
echo "Configuring for first boot"
systemd-firstboot --force --root "${SYSROOT}" \
    --setup-machine-id --keymap=us --locale=en_GB.UTF-8 \
    --prompt-timezone --prompt-root-password --prompt-hostname
echo "Configuring network"
ln -sf /run/systemd/resolve/stub-resolv.conf "${SYSROOT}"/etc/resolv.conf
echo "Enabling services"
systemctl --root "${SYSROOT}" enable \
    systemd-resolved.service systemd-homed.service NetworkManager.service

echo "Building UKIs"
# Make mkinitcpio use systemd
install -Dpm644 -t "${SYSROOT}"/etc/mkinitcpio.d \
    "${DIR}"/etc/mkinitcpio.conf.d/10-swsnr-systemd-base.conf
# Tell kernel-install to use mkinitcpio to build UKIs
install -Dpm644 "${SYSROOT}"/etc/kernel/ "${DIR}"/etc/kernel/install.conf
# Get version of installed kernel
kernel_versions=("${SYSROOT}"/usr/lib/modules/*)
kernel_version="${kernel_versions[0]##*/}"
arch-chroot "${SYSROOT}" kernel-install add "${kernel_version}" \
    "/usr/lib/modules/${kernel_version}/vmlinuz"

echo "Install bootloader"
bootctl --root "${SYSROOT}" install

# Finish things
echo "BOOTSTRAPPING FINISHED"
# shellcheck disable=SC2250
echo "Feel free to perform further setup with 'arch-chroot $SYSROOT'."
echo "Eventually run 'reboot' to boot into the new system."
