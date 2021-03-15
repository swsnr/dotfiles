#!/usr/bin/env python3
# Copyright Sebastian Wiesner <sebastian@swsnr.de>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
Pop Shell launcher plugin for vscode workspaces.

See <https://github.com/pop-os/shell/blob/master/src/plugins/README.md> for the
laucher plugin protocol.
"""

import os
import sys
import json
import logging
from urllib.parse import urlparse
from dataclasses import dataclass
from pathlib import Path
from typing import Any, TypedDict, Optional

from gi.repository import Gio  # pylint: disable=import-error

log = logging.getLogger("pop-shell-launcher-vscode")


@dataclass
class Candidate:
    """
    A VSCode candidate.
    """

    desktop_file: str
    config_dir: str


VSCODE_CANDIDATES: list[Candidate] = [
    # Standard Code OSS build on Arch Linux.
    Candidate(desktop_file="code-oss.desktop", config_dir="Code - OSS"),
    # Offical VSCode snap
    Candidate(desktop_file="code_code.desktop", config_dir="Code"),
    # VSCodium support, Free/Libre Open Source Software Binaries of VSCode.
    Candidate(desktop_file="codium.desktop", config_dir="VSCodium"),
]


@dataclass
class VSCodeRecentWorkspace:
    """
    A recent VSCode workspace.
    """


@dataclass
class VSCodeApp:
    """
    A VSCode App we can use to search for recent workspaces.
    """

    app_info: Gio.AppInfo
    config_dir: Path

    @property
    def icon_name(self) -> str:
        """
        Get the icon name of this VSCode app.
        """
        return self.app_info.get_icon().to_string()

    @property
    def storage_file(self) -> Path:
        """
        The storage file of this VSCode app.
        """
        return self.config_dir / "storage.json"

    def get_recent_workspaces(self) -> list[str]:
        """
        Get the recent workspaces of this VSCode app.

        Return the list of recent workspace URIs.
        """
        with self.storage_file.open() as source:
            storage = json.load(source)
        assert isinstance(storage, dict)
        uris = storage.get("openedPathsList", {}).get("workspaces3", [])
        assert isinstance(uris, list)
        return uris


def xdg_config_home():
    """
    Find the XDG config directory.
    """
    return Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))


def find_vscode():
    """
    Find the installed VSCode variant.
    """
    config_home = xdg_config_home()
    for candidate in VSCODE_CANDIDATES:
        try:
            return VSCodeApp(
                app_info=Gio.DesktopAppInfo.new(candidate.desktop_file),
                config_dir=config_home / candidate.config_dir,
            )
        # pygobject raises a type error if new returns NULL, for whatever reason
        except TypeError:
            continue

    return None


Event = dict[str, Any]


def safe_uri_name(uri: str) -> str:
    """
    Safely get the "name" of the given URI.

    Returns the basename of the path of `uri` or `uri` if it's no valid URI.
    """
    try:
        return urlparse(uri).path.split("/")[-1]
    except Exception:  # pylint: disable=broad-except
        return uri


class Selection(TypedDict):
    """
    A single selection.
    """

    id: int
    name: str
    description: Optional[str]
    icon: Optional[str]
    content_type: Optional[str]


def queried(selections: list[Selection]) -> Event:
    """
    A list of search results to display.
    """
    return {"event": "queried", "selections": selections}


def fill(text: str) -> Event:
    """
    Replaces the launcher text with these contents.
    """
    return {"event": "fill", "text": text}


def close() -> Event:
    """
    Requests to close the launcher
    """
    return {"event": "close"}


def noop() -> Event:
    """
    Tell the shell to do nothing when it expects a response.
    """
    return {"event": "noop"}


@dataclass
class RecentItem:
    """
    A recent item with a name and a URI.
    """

    name: str
    uri: str


class EventHandlers:
    """
    Handler for Pop Shell launcher events.
    """

    _vscode: VSCodeApp

    def __init__(self, vscode: VSCodeApp, recent_items: list[str]):
        """
        Create new Event handlers.
        """
        self._vscode = vscode
        self._recent_items = [
            RecentItem(name=safe_uri_name(uri), uri=uri) for uri in recent_items
        ]
        self._handlers = {
            "complete": self._do_complete,
            "query": self._do_query,
            "quit": self._do_quit,
            "submit": self._do_submit,
        }

    def __call__(self, event: Event) -> Event:
        return self._handlers[event["event"]](event)

    def _do_complete(self, _event: Event) -> Event:
        """
        Handle a `complete` event.

        Tab Completion: Requests for the plugin to complete the search, if
        possible. The plugin should remember the last query it received if it
        intends to complete a query
        """
        # We don't support tab completion for workspaces
        return noop()

    def _do_query(self, event: Event) -> Event:
        """
        Handle a `query` event.

        Fetch a list of search results for the launcher to choose from
        """
        value = event["value"]
        assert isinstance(value, str)
        query = value.lower()
        return queried(
            [
                Selection(
                    id=index,
                    name=item.name,
                    description=f"VSCode workspace {item.uri}",
                    icon=self._vscode.icon_name,
                    content_type=None,
                )
                for index, item in enumerate(self._recent_items)
                if query in item.uri or query in item.name.lower()
            ]
        )

    def _do_quit(self, _event: Event) -> Event:
        """
        Handle a `quit` event.

        Request for the plugin to quit.
        """
        log.info("Exiting in response to quit event")
        sys.exit()

    def _do_submit(self, event: Event) -> Event:
        """
        Handle a `submit` event.

        Request to apply one of the search results that were previously queried.
        """
        selected_id = event["id"]
        assert isinstance(selected_id, int)
        uri = self._recent_items[selected_id].uri
        self._vscode.app_info.launch_uris([uri], None)
        return close()


def write_response(response: Event):
    """
    Write a single response to stdout.
    """
    sys.stdout.write(json.dumps(response))
    sys.stdout.write("\n")
    sys.stdout.flush()


def main():
    """
    Entry point.

    Start reading from stdin for pop shell commands.
    """
    # Try to log directly to journalctl, and fallback to stderr logging which
    # also gets directed to journalctl by Pop Shell
    try:
        from systemd import journal  # pylint: disable=import-outside-toplevel

        log.addHandler(journal.JournalHandler())
    except ImportError:
        logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)

    log.setLevel(logging.WARNING)

    log.info(
        "VScode workspace plugin started, see "
        "https://github.com/lunaryorn/pop-shell-launcher-vscode"
    )

    vscode = find_vscode()
    if vscode:
        log.info("Found vscode %s, config dir %s", vscode.app_info, vscode.config_dir)
        event_handler = EventHandlers(vscode, vscode.get_recent_workspaces())
    else:
        log.warning(
            "VSCode not found!  To add support for your variant of VSCode make "
            "a pull request at "
            "https://github.com/lunaryorn/pop-shell-launcher-vscode/pulls"
        )
        event_handler = None

    for line in sys.stdin:
        event = json.loads(line)
        log.debug("Got event: %r", event)
        assert isinstance(event, dict)
        if event_handler:
            response = event_handler(event)
        else:
            response = noop()
        log.debug("Replying with %r", response)
        write_response(response)


if __name__ == "__main__":
    try:
        main()
    except Exception as error:  # pylint: disable=broad-except
        log.exception("vscode plugin failed: %r", error)
        # Raise the error to make the plugin fail after logging it for debugging purposes.
        raise
