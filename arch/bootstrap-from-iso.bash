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

args=()

use_luks="yes"
target_device=""

while [[ $# -gt 0 ]]
do
    arg="$1"

    case "$arg" in
        "--not-encrypted")
            use_luks="no"
            shift
            ;;
        "--device")
            target_device="$2"
            shift
            shift
            ;;
        *)
            args+=("$arg")
            shift;
    esac
done

if [[ -z "$target_device" ]]; then
    echo "Missing --device <device> argument" >&2
    exit 2;
fi

if [[ "${#args[@]}" -ne 0 ]]; then
    echo "Unexpected extra arguments: ${args[*]}" >&2
    exit 2
fi

if [[ "$UID" -ne 0 ]]; then
    echo "This script needs to be run as root!" >&2
    exit 3
fi

read -rp "THIS SCRIPT WILL OVERWRITE ALL CONTENTS OF ${target_device}. Type uppercase yes to continue: " confirmed

if [[ "$confirmed" != "YES" ]]; then
    echo "aborted" >&2
    exit 128
fi

# Partition
sgdisk -Z "$target_device"
sgdisk \
    -n1:0:+550M  -t1:ef00 -c1:EFISYSTEM \
    -N2          -t2:8304 -c2:linux \
    "$target_device"

# Reload partition table
sleep 3
partprobe -s "$target_device"
sleep 3

# Encrypt root if desired
if [[ "$use_luks" == "yes" ]]; then
    cryptsetup luksFormat --type luks2 \
        /dev/disk/by-partlabel/linux
    cryptsetup luksOpen /dev/disk/by-partlabel/linux root
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
else
    root_device="/dev/disk/by-partlabel/linux"
fi

# Create file systems
mkfs.fat -F32 -n EFISYSTEM /dev/disk/by-partlabel/EFISYSTEM
mkfs.btrfs -f -L linux "$root_device"

SYSROOT="/mnt"

# Mount arch subvolume and create additional subvolumes for rootfs.  Enable
# compression for the bootstrap process.
mount -o 'compress=zstd:1' "$root_device" "$SYSROOT"
mkdir "$SYSROOT"/efi
for subvol in var var/log var/cache var/tmp srv home; do
    btrfs subvolume create "$SYSROOT/$subvol"
done
# Disable CoW for /home due to large loopback files by systemd-homed
chattr +C "$SYSROOT/home"

# Mount additional partitions
mount /dev/disk/by-partlabel/EFISYSTEM "$SYSROOT/efi"

# Generate mirrorlist on the host system for my country
# (The live disk runs reflector, but with global mirror selection).
# pacstrap then copies this mirrorlist to the new root
echo "Bootstrapping"
reflector --save /etc/pacman.d/mirrorlist --protocol https --country Germany --latest 5 --sort age
bootstrap_packages=(
    base
    linux
    linux-firmware
    intel-ucode
    btrfs-progs
    dracut
    # We need a text editor
    neovim
    )
pacstrap -K "$SYSROOT" "${bootstrap_packages[@]}"
# Install optional dependencies required by dracut to generate UKI2
arch-chroot "$SYSROOT" pacman -S --noconfirm --asdeps binutils elfutils

echo "Setting up locales"
sed -i \
    -e '/^#en_GB.UTF-8/s/^#//' \
    -e '/^#de_DE.UTF-8/s/^#//' \
    "$SYSROOT"/etc/locale.gen
echo "Configuring for first boot"
systemd-firstboot --root "$SYSROOT" \
    --keymap=us --locale=en_GB.UTF-8 \
    --prompt-timezone --prompt-root-password --prompt-hostname

ln -sf /run/systemd/resolve/stub-resolv.conf "$SYSROOT"/etc/resolv.conf

echo "Generating locales"
arch-chroot "$SYSROOT" locale-gen
echo "Building UKIs"
arch-chroot "$SYSROOT" dracut -f --uefi --regenerate-all
echo "Install bootloader"
bootctl --root "$SYSROOT" install

echo "Enable systemd services"
systemctl --root "$SYSROOT" enable systemd-resolved systemd-homed

# Finish things
echo "BOOTSTRAPPING FINISHED"
echo "Feel free to perform further setup with 'arch-chroot $SYSROOT'."
echo "Eventually run 'reboot' to boot into the new system."
