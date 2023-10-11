#!/bin/bash

# See https://gjs.guide/extensions/development/debugging.html#running-a-nested-gnome-shell

set -euo pipefail

export G_MESSAGES_DEBUG=all
export MUTTER_DEBUG_DUMMY_MODE_SPECS=1366x768

exec dbus-run-session -- gnome-shell --nested --wayland
