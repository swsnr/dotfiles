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
from signal import SIGUSR1, SIGUSR2
from subprocess import run, Popen
from gi.repository import Gio


SETTINGS = {
    'BLANK_TIMEOUT': 5,
    'BLANK_DPMS_STATE': 'suspend',
    'SHOW_DATETIME': 1,
    'DATETIME_FORMAT': '%A, %Y-%m-%d %H:%M (%V)',
    'FONT': 'PragmataPro',
    'PASSWORD_PROMPT': 'disco',
}


def main():
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
    systemd.KillUnit('(ssi)', 'dunst.service', 'main', SIGUSR1)

    # Settings for xsecurelock
    locker_env = dict(os.environ)
    locker_env.update((f'XSECURELOCK_{key}', str(value))
                      for key, value in SETTINGS.items())
    locker_env['LUNARYORN_LOCKED_SESSION_PATH'] = session.get_object_path()

    # Notify apps that the session is locked after the locker started successfully
    xsecurelock = ['xsecurelock', '--', 'i3-set-session-locked']

    lock_fd = os.environ.get('XSS_SLEEP_LOCK_FD', None)
    if lock_fd:
        # We've inherited a sleep lock from xss-lock; we need to pass it on to
        # xsecurelock while closing our copy of the fd after spawning xsecurelock.
        lock_fd = int(lock_fd)
        lock = Popen(xsecurelock, env=locker_env, pass_fds=[lock_fd])
        os.close(lock_fd)
        lock.wait()
    else:
        # If we don't need to handle the sleep lock just run xsecurelock with our settings
        run(xsecurelock, env=locker_env)

    # Tell apps that the session is now unlocked again.
    session.SetLockedHint('(b)', False)

    # Resume notifications
    systemd.KillUnit('(ssi)', 'dunst.service', 'main', SIGUSR2)


if __name__ == "__main__":
    main()
