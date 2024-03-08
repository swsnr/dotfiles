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
    # Use a custom title bar instead of the native one; the native one is
    # somewhat pointless on Wayland
    "window.titleBarStyle": "custom",
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
    # Terminal: Use fish.
    "terminal.integrated.defaultProfile.linux": "fish",
    "terminal.external.linuxExec": "wezterm",
    "terminal.integrated.enableImages": True,
    # Rust settings
    # Use package-installed rust-analyzer, works better than the built-in one
    "rust-analyzer.server.path": "/usr/bin/rust-analyzer",
    # Use clippy to check, by default
    "rust-analyzer.check.command": "clippy",
    # Build latex w/ latexmk only
    "latex-workshop.latex.recipes": [
        {
            "name": "latexmk (latexmkrc)",
            "tools": [
                "latexmk_rconly",
            ],
        },
    ],
    # Preview latex documents in a tab
    "latex-workshop.view.pdf.viewer": "tab",
    # Language specific settings
    "[toml]": {
        # Don't auto-format toml files
        "editor.formatOnSave": False,
        "editor.formatOnPaste": False,
    },
}


EXTENSIONS = [
    "sonnyp.blueprint-gtk",
    "asciidoctor.asciidoctor-vscode",
    "James-Yu.latex-workshop",
    # Shell scripting with fish and bash
    "bmalehorn.vscode-fish",
    "mads-hartmann.bash-ide-vscode",
    "mkhl.shfmt",
    # Rust support
    "rust-lang.rust-analyzer",
    "serayuzgur.crates",
    "tamasfe.even-better-toml",
    # Python
    "ms-python.python",
    # JS & Typescript,
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "denoland.vscode-deno",
]


def install_extensions() -> None:
    """Install desired vscode extensions."""
    for extension in EXTENSIONS:
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
