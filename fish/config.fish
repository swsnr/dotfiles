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

# Setup for interactive shells
if status --is-interactive
    # Set cursor shape for vi
    set fish_cursor_insert underscore

    # Cleanup on exit
    function cleanup-tokens --on-event fish_exit
        # Remove a few security tokens for the current terminal
        op signout 2>/dev/null
        sudo -K 2>/dev/null
        return 0
    end

    # Give me English messages in an interface shell in a TTY; these messages
    # are just so much better than the translations!
    #
    # Don't do this in a login shell, though, because that'd change the language
    # of the entire desktop, since GDM starts the session through a login shell
    set -x LC_MESSAGES 'en_GB.utf8'

    # Update colours (ls, bat, etc.)
    update-theme

    # Automatically enable NVM and SDK versions for the current directory;
    # this is not a lazy-loaded function because it needs to register on PWD
    # changes immediately.
    function auto_sdk_nvm --on-variable PWD
        if test -e .nvmrc
            nvm use
        end

        if test -e .sdkmanrc
            sdk env
        end
    end

    # diff prog, e.g. for pacdiff
    set -x DIFFPROG 'nvim -d'

    # python -m venv shouldn't change my prompt.
    set -x VIRTUAL_ENV_DISABLE_PROMPT 1

    # Abbreviations (unlike aliases, these are expanded before running)
    # Fast one or two letter abbrevs
    abbr --global --add _ sudo
    abbr --global --add code vscodium
    abbr --global --add dc docker-compose
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
    abbr --global --add du du -kh

    # And some shortcuts
    abbr --global --add mdc mdcat
    abbr --global --add mdl mdcat -p
    abbr --global --add wttr curl wttr.in
end
