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


import logging
import sys
import time
from contextlib import contextmanager
from collections import namedtuple
from argparse import ArgumentParser
from subprocess import run

from systemd.journal import JournalHandler

import gi
gi.require_version('Notify', '0.7')  # nopep8
from gi.repository import Gio, Notify


LOG = logging.getLogger('i3.exit')

# TODO: List inhibitors before shutdown/reboot/sleep


class AbortedWithReason(Exception):
    def __init__(self, reason):
        self.reason = reason

    def __str__(self):
        return self.reason


Window = namedtuple('Window', 'id title')


def _parse_wmctrl_line(line):
    parts = line.split(maxsplit=3)
    if len(parts) == 3:
        (window_id, _desktop, _machine) = parts
        return Window(id=window_id, title=None)
    else:
        (window_id, _desktop, _machine, title) = parts
        return Window(id=window_id, title=title)


def get_open_windows():
    output = run(['wmctrl', '-l'], capture_output=True, text=True).stdout
    LOG.debug(f'wmctrl returned: {output!r}')
    return list(map(_parse_wmctrl_line, output.splitlines()))


def close_window(window):
    LOG.info(f'Asking window {window.id} {window.title} to close')
    run(['wmctrl', '-ic', window.id], check=True)


def close_all_open_windows():
    for window_id in get_open_windows():
        close_window(window_id)


def wait_for_windows_closed(timeout):
    start = time.monotonic()

    while True:
        time.sleep(0.5)
        if not get_open_windows():
            return True
        elif timeout <= (time.monotonic() - start):
            return False


def stop_user_services():
    flags = Gio.DBusProxyFlags.DO_NOT_CONNECT_SIGNALS | Gio.DBusProxyFlags.DO_NOT_LOAD_PROPERTIES
    systemd = Gio.DBusProxy.new_for_bus_sync(
        Gio.BusType.SESSION, flags, None,
        'org.freedesktop.systemd1',
        '/org/freedesktop/systemd1',
        'org.freedesktop.systemd1.Manager'
    )
    services = ['dunst.service', 'redshift.service']
    for unit in services:
        LOG.info(f'Asking service {unit} to stop')
        systemd.StopUnit('(ss)', unit, 'fail')


def close_session():
    close_all_open_windows()
    # Wait some time for all windows to close and fail if windows remain open
    if not wait_for_windows_closed(30):
        raise AbortedWithReason('applications did not close!')

    stop_user_services()


def exit_i3():
    run(['i3-msg', 'exit'], check=True)


@contextmanager
def handle_abort(action):
    try:
        yield
    except AbortedWithReason as reason:
        notification = Notify.Notification.new(
            f'{action} aborted', f'Reason: {reason}')
        notification.set_timeout(5000)
        notification.set_urgency(Notify.Urgency.CRITICAL)
        notification.show()
        LOG.warning(f'{action} aborted with reason: {reason}')
        sys.exit(2)


def _action_exit(args):
    with handle_abort('Logout'):
        close_session()
        exit_i3()
        return 0


def get_login_manager():
    return Gio.DBusProxy.new_for_bus_sync(
        Gio.BusType.SYSTEM, Gio.DBusProxyFlags.DO_NOT_LOAD_PROPERTIES | Gio.DBusProxyFlags.DO_NOT_CONNECT_SIGNALS, None,
        'org.freedesktop.login1',
        '/org/freedesktop/login1',
        'org.freedesktop.login1.Manager'
    )


def _action_suspend(args):
    login_manager = get_login_manager()
    LOG.info('Asking logind to suspend the system (with PolicyKit interaction)')
    login_manager.Suspend('(b)', True)
    return 0


def _action_reboot(args):
    with handle_abort('Reboot'):
        close_session()
        login_manager = get_login_manager()
        LOG.info('Asking logind to reboot the system (with PolicyKit interaction)')
        login_manager.Reboot('(b)', True)
        return 0


def _action_shutdown(args):
    with handle_abort('Shutdown'):
        close_session()
        login_manager = get_login_manager()
        LOG.info('Asking logind to shutdown the system (with PolicyKit interaction)')
        login_manager.Shutdown('(b)', True)
        return 0


def main():
    parser = ArgumentParser(description='Exit i3')
    commands = parser.add_subparsers(description='commands')

    exit = commands.add_parser('exit', description='Exit i3 and logout')
    exit.set_defaults(_action=_action_exit)

    suspend = commands.add_parser('suspend', description='Suspend the system')
    suspend.set_defaults(_action=_action_suspend)

    reboot = commands.add_parser('reboot', description='Exit i3 and reboot')
    reboot.set_defaults(_action=_action_reboot)

    shutdown = commands.add_parser(
        'shutdown', description='Exit i3 and shutdown')
    shutdown.set_defaults(_action=_action_shutdown)

    Notify.init("i3")

    logging.getLogger().addHandler(JournalHandler())
    LOG.setLevel(logging.INFO)

    args = parser.parse_args()

    try:
        sys.exit(args._action(args))
    except Exception as error:
        LOG.exception(f'Exit failed: {error}')
        sys.exit(9)


if __name__ == "__main__":
    main()
