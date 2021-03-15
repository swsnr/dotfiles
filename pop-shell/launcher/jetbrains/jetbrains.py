#!/usr/bin/env python3
# Copyright Sebastian Wiesner <sebastian@swsnr.de>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
Pop Shell launcher plugin for recent Jetbrains projects.

See <https://github.com/pop-os/shell/blob/master/src/plugins/README.md> for the
laucher plugin protocol.
"""

import os
import sys
import logging
import json
import re
import xml.etree.ElementTree as etree
from collections.abc import Iterable
from dataclasses import dataclass
from pathlib import Path
from typing import Any, TypedDict, Optional


from gi.repository import Gio  # pylint: disable=import-error

log = logging.getLogger("pop-shell-launcher-jetbrains")


def xdg_config_home():
    """
    Find the XDG config directory.
    """
    return Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))


@dataclass
class JetbrainsProduct:
    """
    A Jetbrains product.

    A product has an `id` which is used to identify it in dicts,
    a `config_glob` to find its configuration directory, a `vendor_dirname` to
    find the directory to look for in XDG Config Home, and a list of desktop IDs
    the product is known as.
    """

    id: str  # pylint: disable=invalid-name
    config_glob: str
    vendor_dirname: str
    desktop_ids: list[str]

    def find_app(self) -> Optional[Gio.AppInfo]:
        """
        Find an app for this product.
        """
        for desktop_id in self.desktop_ids:
            try:
                # pygobject raises a type error if new returns NULL, for whatever reason
                return Gio.DesktopAppInfo.new(desktop_id)
            except TypeError:
                continue
        return None


@dataclass
class RecentProject:
    """
    A recent project with a name and a path.
    """

    name: str
    path: Path


def read_recent_projects(filename: Path) -> Iterable[RecentProject]:
    """
    Read recent projects from the given file.
    """
    document = etree.parse(filename)
    paths = set(
        Path(el.attrib["value"].replace("$USER_HOME$", "~"))
        for el in document.findall('.//option[@name="recentPaths"]/list/option')
    )
    # Paths structure since IDEA 2020.3
    paths.update(
        Path(el.attrib["key"].replace("$USER_HOME$", "~")).expanduser()
        for el in document.findall(
            './/component[@name="RecentProjectsManager"]/option[@name="additionalInfo"]/map/entry'
        )
    )
    for path in paths:
        if path.exists():
            try:
                name = (path / ".idea" / "name").read_text(encoding="utf-8").strip()
            except FileNotFoundError:
                name = path.name
            yield RecentProject(name=name, path=path)


def get_recent_projects(
    config_home: Path, product: JetbrainsProduct
) -> Iterable[RecentProject]:
    """
    Find the newest recent projects file for Jetbrains.
    """
    entries = (
        (entry, re.search(r"(\d{1,4}).(\d{1,2})", entry.name))
        for entry in (config_home / product.vendor_dirname).glob(product.config_glob)
        if entry.is_dir()
    )
    versioned = (
        (entry, (int(match.group(1)), int(match.group(2))))
        for (entry, match) in entries
        if match
    )
    config_dir = max(versioned, key=lambda i: i[1], default=None)
    if config_dir:
        recentfile = (
            config_dir[0]
            / "options"
            / ("recentSolutions.xml" if product.id == "rider" else "recentProjects.xml")
        )
        yield from read_recent_projects(recentfile)


PRODUCTS: list[JetbrainsProduct] = [
    JetbrainsProduct(
        id="idea",
        config_glob="IntelliJIdea*",
        vendor_dirname="JetBrains",
        desktop_ids=[
            # Arch Linux AUR package and toolbox installation
            "jetbrains-idea.desktop",
            # Snap installation
            "intellij-idea-ultimate_intellij-idea-ultimate.desktop",
            # Flatpak installation
            "com.jetbrains.IntelliJ-IDEA-Ultimate.desktop",
        ],
    ),
    JetbrainsProduct(
        id="idea-ce",
        config_glob="IdeaIC*",
        vendor_dirname="JetBrains",
        desktop_ids=[
            # Toolbox installation
            "jetbrains-idea-ce.desktop",
            # Snap install
            "intellij-idea-community_intellij-idea-community.desktop",
            # Arch Linux package,
            "idea.desktop",
        ],
    ),
    JetbrainsProduct(
        id="webstorm",
        config_glob="WebStorm*",
        vendor_dirname="JetBrains",
        desktop_ids=[
            # Toolbox installation
            "jetbrains-webstorm.desktop",
            # Snap installation
            "webstorm_webstorm.desktop",
        ],
    ),
    JetbrainsProduct(
        id="clion",
        config_glob="CLion*",
        vendor_dirname="JetBrains",
        desktop_ids=[
            # Toolbox installation
            "jetbrains-clion.desktop",
            # Snap installation
            "clion_clion.desktop",
        ],
    ),
    JetbrainsProduct(
        id="goland",
        config_glob="GoLand*",
        vendor_dirname="JetBrains",
        desktop_ids=[
            # Toolbox installation
            "jetbrains-goland.desktop",
        ],
    ),
    JetbrainsProduct(
        id="pycharm",
        config_glob="PyCharm*",
        vendor_dirname="JetBrains",
        desktop_ids=[
            # Toolbox installation
            "jetbrains-pycharm.desktop",
            # Arch Linux User Repository
            "pycharm-professional.desktop",
        ],
    ),
    JetbrainsProduct(
        id="phpstorm",
        config_glob="PhpStorm*",
        vendor_dirname="JetBrains",
        desktop_ids=[
            # Toolbox installation
            "jetbrains-phpstorm.desktop",
            # Snap installation
            "phpstorm_phpstorm.desktop",
        ],
    ),
    JetbrainsProduct(
        id="rider",
        config_glob="Rider*",
        vendor_dirname="JetBrains",
        desktop_ids=[
            # Toolbox installation
            "jetbrains-rider.desktop",
        ],
    ),
    JetbrainsProduct(
        id="android-studio",
        config_glob="AndroidStudio*",
        vendor_dirname="Google",
        desktop_ids=[
            # Toolbox installation
            "jetbrains-studio.desktop",
        ],
    ),
]


Event = dict[str, Any]


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
class RecentProjectOfProduct:
    """
    A recent project associated with a product.
    """

    product: JetbrainsProduct
    app: Gio.AppInfo
    project: RecentProject

    @property
    def name(self) -> str:
        """
        The name of this project.
        """
        return self.project.name

    @property
    def description(self) -> str:
        """
        The description to show in the launcher.
        """
        return f"{self.app.get_name()} project {self.project.path}"

    @property
    def icon(self) -> str:
        """
        The icon.
        """
        icon = self.app.get_icon()
        if isinstance(icon, Gio.ThemedIcon):
            return icon.get_names()[0]
        # FIXME: Currently there's no way for selections to use a file-path as icon,
        # see <https://github.com/pop-os/shell/issues/905>
        # elif isinstance(icon, Gio.FileIcon):
        #     return icon.get_file().get_path()
        else:
            # Fallback to a generic default icon
            return "applications-development"

    def launch(self):
        """
        Start this project.
        """
        self.app.launch_uris([self.project.path.as_uri()])


class EventHandlers:
    """
    Handler for Pop Shell launcher events.
    """

    def __init__(self, projects: list[RecentProjectOfProduct]):
        """
        Create new Event handlers.
        """
        self._projects = projects
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
                    name=project.name,
                    description=project.description,
                    icon=project.icon,
                    content_type=None,
                )
                for index, project in enumerate(self._projects)
                if query in str(project.project.path).lower()
                or query in project.project.name.lower()
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
        self._projects[selected_id].launch()
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
        "Jetbrains projects plugin started, see "
        "https:#github.com/lunaryorn/pop-shell-launcher-jetbrains"
    )

    config_home = xdg_config_home()
    apps = ((product, product.find_app()) for product in PRODUCTS)
    recent_projects = [
        RecentProjectOfProduct(product, app, project)
        for (product, app) in apps
        for project in get_recent_projects(config_home, product)
        if app
    ]
    event_handler = EventHandlers(recent_projects)

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
        log.exception("jetbrains plugin failed: %r", error)
        # Raise the error to make the plugin fail after logging it for debugging purposes.
        raise
