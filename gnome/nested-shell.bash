#!/bin/bash

# See https://gjs.guide/extensions/development/debugging.html#running-a-nested-gnome-shell

set -euo pipefail

# See https://gitlab.gnome.org/GNOME/mutter/-/blob/main/src/backends/meta-monitor-manager-dummy.c
# for documentation of these variables.
#
# If setting a scale > 1 the mode spec must at least be 1024x768 * scale, to provide
# a minimum effective resolution of 1024x768.  Smaller scales will be ignored.
export MUTTER_DEBUG_DUMMY_MODE_SPECS=2048x1536
export MUTTER_DEBUG_DUMMY_MONITOR_SCALES=2

exec dbus-run-session -- gnome-shell --nested --wayland
