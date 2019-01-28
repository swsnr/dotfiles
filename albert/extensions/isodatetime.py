# -*- coding: utf-8 -*-

# Copyright (C) 019 Sebastian Wiesner <sebastian@swsnr.de>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

"""Copy ISO date to clipboard

"""

__iid__ = "PythonInterface/v0.2"
__prettyname__ = "ISO Date and Time"
__version__ = "0.1"
__trigger__ = "isodt"
__author__ = "Sebastian Wiesner"
__dependencies__ = []

from albertv0 import *
from datetime import *

def handleQuery(query):
    if not query.isTriggered:
        return None

    now = datetime.now()

    return [
        Item(
            id=id,
            text=text,
            icon=iconLookup("x-office-calendar"),
            subtext=subtext,
            completion=text,
            actions=[ClipAction(label, text)]
        )
        for id, text, subtext, label in [
            ('isodate-1-date', now.date().isoformat(), 'Today', 'Copy date to clipboard'),
            ('isodate-2-time', now.time().isoformat('seconds'), 'Current time', 'Copy current time to clipboard'),
            ('isodate-3-time', now.isoformat('T', 'seconds'), 'Now', 'Copy current date and time to clipboard'),
        ]
    ]
