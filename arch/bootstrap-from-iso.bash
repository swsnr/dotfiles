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
new_hostname=""

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
        "--hostname")
            new_hostname="$2"
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

if [[ -z "$new_hostname" ]]; then
    echo "Missing --hostname <hostname> argument" >&2
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
sgdisk -Z /dev/vda
sgdisk \
    -n1:0:+500M  -t1:ef00 -c1:EFISYSTEM \
    -n2:0:+1000M -t2:ea00 -c2:XBOOTLDR \
    -N3          -t3:8304 -c3:linux \
    "$target_device"

# Reload partition table
sleep 1
partprobe -s "$target_device"

# Encrypt root if desired
if [[ "$use_luks" == "yes" ]]; then
    cryptsetup luksFormat /dev/disk/by-partlabel/linux
    cryptsetup luksOpen /dev/disk/by-partlabel/linux root
    root_device="/dev/mapper/root"
else
    root_device="/dev/disk/by-partlabel/linux"
fi

# Create file systems
mkfs.fat -F32 -n EFISYSTEM /dev/disk/by-partlabel/EFISYSTEM
mkfs.fat -F32 -n XBOOTLDR /dev/disk/by-partlabel/XBOOTLDR
mkfs.btrfs -f -L linux "$root_device"

# Create default "arch" subvolume
mount "$root_device" /mnt
btrfs subvolume create /mnt/arch
btrfs subvolume set-default /mnt/arch
umount /mnt

# Mount arch subvolume and create additional subvolumes for rootfs
mount "$root_device" /mnt
mkdir /mnt/{boot,efi}
for subvol in var var/log var/cache var/tmp srv home; do
    btrfs subvolume create "/mnt/$subvol"
done

# Mount additional partitions
mount /dev/disk/by-partlabel/EFISYSTEM /mnt/efi
mount /dev/disk/by-partlabel/XBOOTLDR /mnt/boot

# Bootstrap new chroot
reflector --save /etc/pacman.d/mirrorlist --protocol https --country Germany --latest 5 --sort age
pacstrap /mnt base linux linux-lts linux-firmware intel-ucode btrfs-progs dracut neovim

# Configure timezone, locale, keymap
ln -sf /usr/share/zoneinfo/Europe/Berlin /mnt/etc/localtime
sed -i \
    -e '/^#en_GB.UTF-8/s/^#//' \
    -e '/^#de_DE.UTF-8/s/^#//' \
    /etc/locale.gen
echo 'LANG=en_GB.UTF-8' >/mnt/etc/locale.conf
echo 'KEYMAP=us' >/mnt/etc/vconsole.conf

# Basic network configuration
echo "$new_hostname" >/mnt/etc/hostname
cat <<EOF >/mnt/etc/hosts
# Static table lookup for hostnames.
# See hosts(5) for details.

127.0.0.1 localhost
::1 localhost
127.0.1.1 $new_hostname.localdomain $new_hostname
EOF

# Switch into chroot
cat <<'EOF' | arch-chroot /mnt
set -xeuo pipefail
# Generate locales
locale-gen
# Install dracut opt deps required to build unified kernel images
pacman -S --noconfirm --asdeps binutils elfutils
for kver in /lib/modules/*; do dracut -f --uefi --kver "${kver##*/}"; done
# Install bootloader
bootctl install
EOF

echo "Set root password"
passwd -R /mnt root

# Finish things
echo "BOOTSTRAPPING FINISHED"
echo "Feel free to perform further setup with 'arch-chroot /mnt'."
echo "Eventually run 'reboot' to boot into the new system."
