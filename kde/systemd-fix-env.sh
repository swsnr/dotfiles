# shellcheck shell=sh

# Import PATH from systemd into this shell, and source profile again.
#
# For some reason KDE doesn't launch its startup shell as child of systemd, so
# we have two paths: The one in systemd which we configure, and some bash path
# from the login shell where all the /etc/profile.d stuff ends up. At the end
# of startup KDE apparently imports the entire shell path into systemd, thus
# overwriting all our customizations.
export "$(systemctl --user show-environment | grep '^PATH=')"
# We can't control the global profile so there's no point in checking it
# shellcheck source=/dev/null
. /etc/profile
