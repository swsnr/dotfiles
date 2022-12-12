# Default imports for my interactive sessions
import os
import sys
from pathlib import Path

def _interactive_hook():
    print('Hello :)')
    def _configure_readline():
        import readline
        import atexit
        import rlcompleter

        # Reading the initialization (config) file may not be enough to set a
        # completion key, so we set one first and then read the file.
        readline_doc = getattr(readline, '__doc__', '')
        if readline_doc is not None and 'libedit' in readline_doc:
            readline.parse_and_bind('bind ^I rl_complete')
        else:
            readline.parse_and_bind('tab: complete')

        try:
            readline.read_init_file()
        except OSError:
            # An OSError here could have many causes, but the most likely one
            # is that there's no .inputrc file (or .editrc file in the case of
            # Mac OS X + libedit) in the expected location.  In that case, we
            # want to ignore the exception.
            pass

        default_state_directory = os.path.join(os.path.expanduser('~'),
                                               '.local', 'state')
        state_directory = os.environ.get('XDG_STATE_HOME',
                                         default_state_directory)
        python_state_directory = os.path.join(state_directory, 'python')
        os.makedirs(python_state_directory, exist_ok=True)

        histfile = os.path.join(python_state_directory, 'python_history')
        try:
            readline.read_history_file(histfile)
            readline.set_history_length(10000)
        except FileNotFoundError:
            pass

        atexit.register(readline.write_history_file, histfile)

    _configure_readline()

sys.__interactivehook__ = _interactive_hook
del _interactive_hook
