#!/usr/bin/env python3
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


"""Configure KDE."""


# TODO: Import shortcuts
# TODO: Configure KMail
# TODO: Configure KDE itself?


import os
from pathlib import Path
from subprocess import run

XDG_CONFIG_HOME = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))


CONFIGURATION = {
    # Plasma settings
    "PlasmaUserFeedback": {
        # Disable Plasma user feedback
        "Global": {
            "FeedbackLevel": None,
        },
    },
    # Global KDE settings
    "kdeglobals": {
        "KDE": {
            # Require double click for actions, for consistency with most other
            # desktops (e.g. Windows, Gnome, etc.)
            "SingleClick": False,
        },
    },
    # KDE window management
    "kwinrc": {
        # Enable night colors based on current location
        "NightColor": {
            "Active": True,
        },
        # Close active window with middle click on title bar
        "MouseBindings": {
            "CommandActiveTitlebar2": "Close",
        },
        # Use a simple and fast thumbnails layout for Alt+Tab; I find the
        # default "breeze" sidebar cool, but also distracting.  For Win+Tab use
        # a fancy and cool 3D gallery
        "TabBox": {
            "LayoutName": "thumbnails",
        },
        "TabBoxAlternative": {
            "LayoutName": "coverswitch",
        },
        # Window effect settings
        "Plugins": {
            # Dim screen when asked for admin password
            "kwin4_effect_dimscreenEnabled": True,
            # Do not dim inactive windows
            "diminactiveEnabled": False,
        },
    },
    # Lock screen
    "kscreenlockerrc": {
        "Daemon": {
            # Automatically lock screen after five minutes, but allow unlock
            # without password for 10s to quickly unlock in case of an undesired
            # screen lock.
            "Timeout": "5",
            "LockGrace": "10",
        },
        "Greeter": {
            # Use picture of the day on the lockscreen; the default picture
            # provider is NASA APOD already
            "WallpaperPlugin": "org.kde.potd",
        },
    },
}


def kwriteconfig(file: Path | str, group: str, key: str,
                 value: None | str | bool) -> None:
    """Write a configuration value to the given file.

    Relative paths in `file` are relative to `XDG_CONFIG_HOME`,
    e.g. `~/.config/`.

    :param file: The file to write to
    :param group: The group to write to
    :param key: The key to write
    :param value: The value; `None` deletes the key instead.
    """
    file = Path(file)
    if not file.is_absolute():
        file = XDG_CONFIG_HOME / file
    command = ["/usr/bin/kwriteconfig5", "--file", str(file),
        "--group", group, "--key", key]
    if value is None:
        command.append("--delete")
    elif isinstance(value, bool):
        command.extend(["--type", "bool", "true" if value else "false"])
    else:
        command.append(value)
    run(command, check=True)


def reload_configuration() -> None:
    """Reload configuration of all affected KDE programs."""
    print("Reloading KWin configuration") # noqa: T201
    run(["/usr/bin/qdbus", "org.kde.KWin", "/KWin", "org.kde.KWin.reconfigure"],
        check=True)


def main() -> None:
    """Entry point for this script."""
    for file, items in CONFIGURATION.items():
        for group, keys in items.items():
            for key, value in keys.items():
                print(f"Write {file} {group} {key} {value}") # noqa: T201
                kwriteconfig(file, group, key, value)

    reload_configuration()


if __name__ == "__main__":
    main()
