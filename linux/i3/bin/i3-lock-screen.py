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
from signal import SIGUSR1, SIGUSR2
from subprocess import run, Popen
from gi.repository import Gio


LOG = logging.getLogger('i3-lock-screen')


SETTINGS = {
    'BLANK_TIMEOUT': 5,
    'BLANK_DPMS_STATE': 'suspend',
    'SHOW_DATETIME': 1,
    'DATETIME_FORMAT': '%A, %Y-%m-%d %H:%M (%V)',
    'FONT': 'PragmataPro',
    'PASSWORD_PROMPT': 'disco',
}


def lock_screen():
    # Connect to systemd and logind
    flags = Gio.DBusProxyFlags.DO_NOT_LOAD_PROPERTIES | Gio.DBusProxyFlags.DO_NOT_CONNECT_SIGNALS
    systemd = Gio.DBusProxy.new_for_bus_sync(
        Gio.BusType.SESSION, flags, None,
        'org.freedesktop.systemd1',
        '/org/freedesktop/systemd1',
        'org.freedesktop.systemd1.Manager'
    )
    session = Gio.DBusProxy.new_for_bus_sync(
        Gio.BusType.SYSTEM, flags, None,
        'org.freedesktop.login1',
        '/org/freedesktop/login1/session/auto',
        'org.freedesktop.login1.Session'
    )

    # Suspend notifications
    LOG.info('Screen about to lock, suspending dunst notifications')
    systemd.KillUnit('(ssi)', 'dunst.service', 'main', SIGUSR1)

    # Settings for xsecurelock
    locker_env = dict(os.environ)
    locker_env.update((f'XSECURELOCK_{key}', str(value))
                      for key, value in SETTINGS.items())

    # Notify apps that the session is locked after the locker started successfully
    xsecurelock = ['xsecurelock', '--', 'i3-set-session-locked']

    lock_fd = os.environ.get('XSS_SLEEP_LOCK_FD', None)
    if lock_fd:
        LOG.info(
            f'Screen locking, starting {xsecurelock} with sleep lock at fd {lock_fd}')
        # We've inherited a sleep lock from xss-lock; we need to pass it on to
        # xsecurelock while closing our copy of the fd after spawning xsecurelock.
        lock_fd = int(lock_fd)
        lock = Popen(xsecurelock, env=locker_env, pass_fds=[lock_fd])
        LOG.debug(f'Closing our copy of sleep lock fd {lock_fd}')
        os.close(lock_fd)
        lock.wait()
    else:
        LOG.info(f'Screen locking, starting {xsecurelock} without sleep lock')
        # If we don't need to handle the sleep lock just run xsecurelock with our settings
        run(xsecurelock, env=locker_env)

    LOG.info('Screen unlocked, updating session state')
    session.SetLockedHint('(b)', False)

    LOG.info('Screen unlocked, resuming dunst notifications')
    systemd.KillUnit('(ssi)', 'dunst.service', 'main', SIGUSR2)


def main():
    logging.getLogger().addHandler(JournalHandler())
    LOG.setLevel(logging.INFO)

    try:
        lock_screen()
    except Exception as error:
        LOG.exception(f'Failed to lock screen: {error}')


if __name__ == "__main__":
    main()
