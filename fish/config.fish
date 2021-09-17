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

# Paths, only for login shells
if status --is-login
    # Local per-user binaries, Rust tools, local gems, etc.
    set -p PATH \
        # My local binaries, from dotfiles and homebins
        ~/.local/bin \
        # Scala tooling
        ~/.local/share/coursier/bin \
        # Rustup tooling
        ~/.cargo/bin
end

# Environment variables.  Use absolute path to nvim because it's likely in a
# non-standard location where sudoedit won't pick it up if it's just the name.
set -x EDITOR (type -p nvim)
set -x PAGER less
set -x BROWSER xdg-open

# Leave my $HOME alone, go
set -x GOPATH $HOME/Code/go

# Make firefox use wayland
set -x MOZ_ENABLE_WAYLAND 1
# ... and fix remoting (see https://wiki.archlinux.org/title/firefox#Applications_on_Wayland_can_not_launch_Firefox)
set -x MOZ_DBUS_REMOTE 1

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
set -x LESS '-q -g -i -M -R -S -w -z-4 -X -K -F'
# Colorize less, see
# <https://wiki.archlinux.org/index.php/Color_output_in_console#Using_less> and
# <https://unix.stackexchange.com/a/108840/38243>
set -x LESS_TERMCAP_mb (set_color -i magenta) # Begin blink
set -x LESS_TERMCAP_md (set_color -o blue) # Begin bold
set -x LESS_TERMCAP_me (set_color normal) # Reset bold/blink
set -x LESS_TERMCAP_so (set_color -r yellow) # Start reverse video
set -x LESS_TERMCAP_se (set_color normal) # Reset reverse video
set -x LESS_TERMCAP_us (set_color -u green) # Start underline
set -x LESS_TERMCAP_ue (set_color normal) # End reverse video

# Extra things for interactive shells
if status --is-interactive
    # Set cursor shape for vi
    set fish_cursor_insert underscore

    # Give me English messages in an interface shell in a TTY; these messages
    # are just so much better than the translations!
    #
    # Don't do this in a login shell, though, because that'd change the language
    # of the entire desktop, since GDM starts the session through a login shell
    set -x LC_MESSAGES 'en_GB.utf8'

    # python -m venv shouldn't change my prompt.
    set -x VIRTUAL_ENV_DISABLE_PROMPT 1

    # Update colours (ls, bat, etc.)
    update-theme

    if command -q rbenv
        # Initialize rbenv for ruby
        rbenv init - | source
    end

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

    # To view files in aur-sync
    set -x AUR_PAGER 'nnn -e'

    # Packager ID for makepkg
    set -x PACKAGER "Sebastian Wiesner <sebastian@swsnr.de>"

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
    abbr --global --add t todo.sh
    abbr --global --add y yarn

    # Default args for some commands
    abbr --global --add df df -kh
    abbr --global --add du du -kh

    # And some shortcuts
    abbr --global --add mdc mdcat
    abbr --global --add mdl mdcat -p
    abbr --global --add wttr curl wttr.in
end
