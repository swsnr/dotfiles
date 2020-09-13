#!/usr/bin/env python3
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


import os
import logging
from systemd.journal import JournalHandler
from gi.repository import Gio


LOG = logging.getLogger('i3-set-session-locked')


def set_session_locked():
    LOG.info('Screen successfully locked, marking session as locked')
    flags = Gio.DBusProxyFlags.DO_NOT_LOAD_PROPERTIES | Gio.DBusProxyFlags.DO_NOT_CONNECT_SIGNALS
    session = Gio.DBusProxy.new_for_bus_sync(
        Gio.BusType.SYSTEM, flags, None,
        'org.freedesktop.login1',
        '/org/freedesktop/login1/session/auto',
        'org.freedesktop.login1.Session'
    )
    # Tell apps that the session is now locked.
    session.SetLockedHint('(b)', True)


def main():
    logging.getLogger().addHandler(JournalHandler())
    LOG.setLevel(logging.INFO)

    try:
        set_session_locked()
    except Exception as error:
        LOG.error(f'Failed to set session locked hint: {error}')


if __name__ == "__main__":
    main()
