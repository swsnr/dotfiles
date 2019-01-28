# -*- coding: utf-8 -*-

"""Copy ISO date to clipboard

"""

__iid__ = "PythonInterface/v0.2"
__prettyname__ = "ISO Date"
__version__ = "1.1"
__trigger__ = "isodt"
__author__ = "Sebastian Wiesner"
__dependencies__ = []

from albertv0 import *
from datetime import *

def handleQuery(query):
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
