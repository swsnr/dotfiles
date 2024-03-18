# Copyright Sebastian Wiesner <sebastian@swsnr.de>
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

set -x EDITOR helix
set -x PAGER moar

# Default less options:
#
# -q: Do not beep
# -g: Highlight search results
# -i: Ignore case when searching
# -M: Prompt verbosely
# -R: Print ANSI color sequences
# -S: Cut of long lines instead of wrapping them
# -w: Highlight the first new line after scrolling
# -z: Keep four lines when scrolling
# -X: Don't set initialization termcap stuff to terminal, to avoid unintended side-effects
# -K: Exit on interrupt
# -F: Exit immediately if content fits on screen
# --use-color: Enable colour output
# -Dd+b: Add blue colour to bold text
# -Du+g: Add green colour to underline text
# -Dk+m: Add magenta colour to blinking text
# -Ds+y: Add yellow colour to standout text
set -x LESS '-q -g -i -M -R -S -w -z-4 -X -K -F --use-color -Dd+b$Du+g$Dk+m$Ds+y'

# Disable default line numbers, as this really interferes with bat
set -x MOAR --no-linenumbers

# Setup for interactive shells
if status --is-interactive
    # Set cursor shape for vi
    set fish_cursor_insert underscore

    # Give me English messages in an interface shell in a TTY; these messages
    # are just so much better than the translations!
    #
    # Don't do this in a login shell, though, because that'd change the language
    # of the entire desktop, since GDM starts the session through a login shell
    set -x LC_MESSAGES 'en_GB.utf8'

    # Update colours (ls, bat, etc.) immediately, and whenever we receive SIGUSR1
    # This lets wezterm refresh the shell theme whenever the background color changes,
    # i.e. when switching between light and dark modes.
    update-theme
    function __update_theme_on_usr1 --on-signal USR1
        update-theme
    end
    if not set -q SSH_CONNECTION
        # Tell wezterm (or any other terminal which might be interested) about
        # our PID Our wezterm configuration uses this PID to send USR1 to fish
        # whenever the appearance changes, prompting our signal handler above to
        # refresh color themes inside this fish instance.
        #
        # We only do this if we're not on an SSH connection; wezterm won't
        # know how to deal with PIDs of remote processes.
        wezterm_set_user_var fish_pid $fish_pid
    end

    # Directory jumping
    if command -q zoxide
        zoxide init fish | source
    end

    # python -m venv shouldn't change my prompt.
    set -x VIRTUAL_ENV_DISABLE_PROMPT 1

    # Setup automatic node and ruby version management
    if command -q fnm
        fnm env | source
        function _fnm_autoload_hook --on-variable PWD --description 'Change Node version on directory change'
            status --is-command-substitution; and return
            # Only search for version files inside my code directory
            if string match -q $HOME/'Code/*' $PWD
                # Silence any error messages
                fnm use --corepack-enabled --version-file-strategy=recursive --silent-if-unchanged 2>/dev/null
            end
        end
    end

    # On Termux start ssh-agent, because termux doesn't do this for us.  On
    # other systems, e.g. Linux, etc. this is handled by the desktop keyring or
    # by 1password.  Only do this for login shells, so that nested terminals in
    # don't spawn a new agent instance.
    if set -q ANDROID_ROOT && set -q TERMUX_VERSION && status is-login
        eval (ssh-agent -c)
    end

    # Abbreviations (unlike aliases, these are expanded before running)
    # Fast one or two letter abbrevs
    abbr --global --add _ sudo
    abbr --global --add e eval '$EDITOR'
    abbr --global --add g git
    abbr --global --add jc journalctl
    abbr --global --add jcu journalctl --user
    abbr --global --add o open
    abbr --global --add rw rename-window
    abbr --global --add s sbt
    abbr --global --add sc systemctl
    abbr --global --add scu systemctl --user
    abbr --global --add y yarn

    # Default args for some commands
    abbr --global --add df df -kh
    abbr --global --add du du -h
end
