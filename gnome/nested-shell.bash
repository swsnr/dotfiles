#!/bin/bash
set -euo pipefail
exec dbus-run-session -- gnome-shell --nested --wayland
