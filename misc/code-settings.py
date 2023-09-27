#!/usr/bin/python3
# Copyright 2020 Sebastian Wiesner <sebastian@swsnr.de>
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

"""Configure VSCode."""


import json
from subprocess import run
from pathlib import Path


SETTINGS = {
    # Disable telemetry
    "telemetry.telemetryLevel": "off",
    # Colors (follow the system on colors)
    "window.autoDetectColorScheme": True,
    # Fonts
    "editor.fontFamily": '"Jetbrains Mono","Noto Color Emoji"',
    "editor.fontLigatures": True,
    "editor.fontSize": 14,
    "terminal.integrated.fontFamily": "Jetbrains Mono",
    "terminal.integrated.fontSize": 14,
    # Fix terminal colours; this a really stupid default imho
    "terminal.integrated.drawBoldTextInBrightColors": False,
    # Editing
    "editor.rulers": [
        80,
        120,
        160,
    ],
    "editor.formatOnPaste": False,
    "editor.formatOnSave": True,
    "files.trimTrailingWhitespace": True,
    "files.insertFinalNewline": True,
    "files.autoSave": "onFocusChange",
    # Version control
    "git.confirmSync": False,
    "git.autofetch": False,
    # File explorer
    "explorer.confirmDragAndDrop": False,
    "explorer.confirmDelete": False,
    # Rust settings
    # Use package-installed rust-analyzer, works better than the built-in one
    "rust-analyzer.server.path": "/usr/bin/rust-analyzer",
    # Use clippy to check, by default
    "rust-analyzer.checkOnSave.command": "clippy",
}


EXTENSIONS = [
    "bmalehorn.vscode-fish",
    # Rust support
    "rust-lang.rust-analyzer",
    "serayuzgur.crates",
    "tamasfe.even-better-toml",
]


def install_extensions() -> None:
    """Install desired vscode extensions."""
    installed = set(run(
        ["/usr/bin/code", "--list-extensions"], text=True, check=True,
            capture_output=True).stdout.splitlines())
    for extension in EXTENSIONS:
        if extension not in installed:
            run(["/usr/bin/code", "--install-extension", extension], check=True)


def update_config() -> None:
    """Update code configuration.

    Read the vscode settings file, change specified settings and write it back again.
    """
    config_file = Path.home() / ".config" / "Code - OSS" / "User" / "settings.json"
    settings = {}
    if config_file.is_file():
        with config_file.open() as source:
            settings = json.load(source)
    settings.update(SETTINGS)
    config_file.parent.mkdir(parents = True, exist_ok = True)
    with config_file.open("w") as sink:
        json.dump(settings, sink, indent=4)


def main() -> None:
    """Configure VSCode and install extensions."""
    update_config()
    install_extensions()


if __name__ == "__main__":
    main()
