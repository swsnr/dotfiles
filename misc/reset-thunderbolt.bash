#!/bin/bash

# Reset thunderbolt devices in case USB devices stop working.
#
# Taken from <https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1766076/comments/81>
#
# See also <https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1766076/>

if [ $EUID != 0 ]; then
    echo "Root required, elevating with sudo $0 $*"
    exec sudo "$0" "$@"
fi

files=(/sys/bus/pci/drivers/xhci_hcd/*[0-9]*)
tbtid=("${files[@]##*/}")

echo 'Resetting thunderbolt bus' >&2
for id in "${tbtid[@]}"; do
  echo "Unbind ${id}" >&2
  echo -n "${id}" > /sys/bus/pci/drivers/xhci_hcd/unbind
done

sleep 1

for id in "${tbtid[@]}"; do
  echo "Bind ${id}" >&2
  echo -n "${id}" > /sys/bus/pci/drivers/xhci_hcd/bind
done

echo 'Done resetting thunderbolt bus' >&2
