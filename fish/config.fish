# Copyright 2018-2019 Sebastian Wiesner <sebastian@swsnr.de>
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
    # Personal binaries and Rust tools
    set -x PATH \
        ~/.local/bin \
        ~/.cargo/bin \
        $PATH

    if uname -s | grep -qi linux
        # Make Qt5 appearance configurable
        set -x QT_QPA_PLATFORMTHEME qt5ct
    end
end

# Environment variables
set -x EDITOR 'code -nw'
set -x PAGER 'less'
set -x BROWSER 'xdg-open'

# Additional cows for cowsay, if existing
if [ -d ~/.cowsay ]
    set -x COWPATH "$HOME/.cowsay:$COWPATH"
end

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

# Extra things for interactive shells
if status --is-interactive

    # Give me English messages in an interface shell in a TTY; these messages
    # are just so much better than the translations!
    #
    # Don't do this in a login shell, though, because that'd change the language
    # of the entire desktop, since GDM starts the session through a login shell
    set -x LC_MESSAGES 'en_GB.utf8'

    # Setup virtualenv helper for Python
    if command -q 'python3'
        python3 -m virtualfish 2>/dev/null | source
    end

    # Detect terminal background color and adapt color themes accordingly.
    #
    # term-background is from https://github.com/lunaryorn/term-background.rs
    if command -q 'term-background'
        set -x LY_TERM_BACKGROUND (term-background --timeout 1000 (tty))
    end

    # Adapt shell environment to background color
    if string match -q light $LY_TERM_BACKGROUND
        set -x BAT_THEME 'OneHalfLight'
        set DIRCOLORS_THEME 'ayu'
    else
        set -x BAT_THEME 'OneHalfDark'
        set DIRCOLORS_THEME 'molokai'
    end

    # dircolors, by vidid <https://github.com/sharkdp/vivid>
    if command -q vivid
        set -x LS_COLORS (vivid generate $DIRCOLORS_THEME)
    end

    # Abbreviations (unlike aliases, these are expanded before running)
    abbr --add _ sudo
    abbr --add df df -kh
    abbr --add du du -kh
    abbr --add e eval '$EDITOR'
    abbr --add o open
    abbr --add g git
    abbr --add pbc pbcopy
    abbr --add pbp pbpaste

    abbr --add sc systemctl
    abbr --add scu systemctl --user
    abbr --add jc journalctl
    abbr --add jcu journalctl --user
    abbr --add dc docker-compose

    abbr --add wttr curl wttr.in
end
