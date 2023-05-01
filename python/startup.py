# ruff: noqa: INP001, D100

# Default imports for my interactive sessions
import os
import sys
import contextlib
from pathlib import Path


def _interactive_hook() -> None:
    """My personal interactive hookself.

    Setup readline completion, and move python history to `$XDG_STATE_HOME`.
    """
    print("Hello :)") # noqa: T201
    def _configure_readline() -> None:
        """Configure readline.

        Setup readline completion, and move readline history to `$XDG_STATE_HOME`.
        """
        import readline
        import atexit

        # Reading the initialization (config) file may not be enough to set a
        # completion key, so we set one first and then read the file.
        readline_doc = getattr(readline, "__doc__", "")
        if readline_doc is not None and "libedit" in readline_doc:
            readline.parse_and_bind("bind ^I rl_complete")
        else:
            readline.parse_and_bind("tab: complete")

        with contextlib.suppress(OSError):
            readline.read_init_file()

        state_directory = Path(os.environ.get(
            "XDG_STATE_HOME", Path.home() / ".local" / "state",
        )) / "python"
        state_directory.mkdir(parents=True, exist_ok=True)

        histfile = state_directory / "python_history"

        try:
            readline.read_history_file(str(histfile))
            readline.set_history_length(10000)
        except FileNotFoundError:
            pass

        atexit.register(readline.write_history_file, histfile)

    _configure_readline()

sys.__interactivehook__ = _interactive_hook
del _interactive_hook
