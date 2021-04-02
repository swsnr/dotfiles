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
Pop Shell launcher plugin for 1password.

See <https://github.com/pop-os/shell/blob/master/src/plugins/README.md> for the
laucher plugin protocol.
"""

import logging
import sys
import json
from argparse import ArgumentParser
from subprocess import run, Popen
from datetime import datetime
from typing import Any, TypedDict, Optional

import gi

gi.require_version("Secret", "1")
gi.require_version("Notify", "0.7")

from gi.repository import Secret, Notify, GLib

log = logging.getLogger("pop-shell-launcher-vscode")

OP_SESSION_SCHEMA = Secret.Schema.new(
    "de.swsnr.1password-session",
    Secret.SchemaFlags.NONE,
    {
        "timestamp": Secret.SchemaAttributeType.INTEGER,
    },
)

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


class EventHandlers:
    """
    Handler for Pop Shell launcher events.
    """

    def __init__(self):
        """
        Create new Event handlers.
        """
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
        # We don't support tab completion
        return noop()

    def _do_query(self, event: Event) -> Event:
        """
        Handle a `query` event.

        Fetch a list of search results for the launcher to choose from
        """
        value = event["value"]
        assert isinstance(value, str)
        return self._query(value.lower())

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
        log.info("Activating item %s", selected_id)
        return self._submit(selected_id)

    def _query(self, query: str) -> Event:
        raise NotImplementedError()

    def _submit(self, id: int) -> Event:
        raise NotImplementedError()


class SigninEventHandlers(EventHandlers):
    def __init__(self):
        super().__init__()

    def _query(self, query: str) -> Event:
        return queried(
            [
                Selection(
                    id=1,
                    name="Sign in",
                    description="Sign in to 1password",
                    icon="1password",
                    content_type=None,
                )
            ]
        )

    def _submit(self, id: int) -> Event:
        assert id == 1
        # Asynchronously restart ourselves to perform the actual signin. If we directly opened a password input here
        # the shell just freezes over; apparently pop-shell synchronously waits for the response and is entirely unable
        # to process input or windows meanwhile :|
        # See <https://github.com/pop-os/shell/issues/903>
        Popen([__file__, "--signin"])
        return close()


def write_response(response: Event):
    """
    Write a single response to stdout.
    """
    sys.stdout.write(json.dumps(response))
    sys.stdout.write("\n")
    sys.stdout.flush()


def start_plugin():
    log.info(
        "1password workspace plugin started, see "
        "https://github.com/lunaryorn/pop-shell-launcher-1password"
    )

    # TODO: Check whether 1password CLI is installed
    event_handler = SigninEventHandlers()

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


def main():
    """
    Entry point.

    Start reading from stdin for pop shell commands.
    """
    # Try to log directly t o journalctl, and fallback to stderr logging which
    # also gets directed to journalctl by Pop Shell
    try:
        from systemd import journal  # pylint: disable=import-outside-toplevel

        log.addHandler(journal.JournalHandler())
    except ImportError:
        logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)

    log.setLevel(logging.DEBUG)

    parser = ArgumentParser()
    parser.add_argument("--signin", action="store_true")
    args = parser.parse_args()

    if args.signin:
        Notify.init("1password")

        log.debug("Asked to perform signin")
        result = run(
            ["zenity", "--modal", "--password"],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            log.info("Signin cancelled")
            sys.exit(1)

        password = result.stdout.rstrip()
        if password:
            result = run(
                ["op", "signin", "--raw"],
                capture_output=True,
                text=True,
                input=password,
            )

            if result.returncode != 0:
                log.warning("Signin failed")
                notification = Notify.Notification.new(
                    "1password signin failed",
                    "Incorrect password for 1password",
                    "1password",
                )
                notification.set_timeout(Notify.EXPIRES_DEFAULT)
                notification.set_hint("transient", GLib.Variant("b", True))
                notification.show()
                sys.exit(1)
            else:
                token = result.stdout.rstrip()
                log.debug("Login successful, storing token %s", token)
                # Store the session token in libsecret
                Secret.password_store_sync(
                    OP_SESSION_SCHEMA,
                    {"timestamp": int(datetime.utcnow().timestamp())},
                    Secret.COLLECTION_SESSION,
                    "pop-shell 1password launcher session",
                    token,
                    None,
                )
                log.info("Login successful")
    else:
        start_plugin()


if __name__ == "__main__":
    try:
        main()
    except Exception as error:  # pylint: disable=broad-except
        log.exception("1password plugin failed: %r", error)
        # Raise the error to make the plugin fail after logging it for debugging purposes.
        raise
