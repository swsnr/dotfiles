# Copyright 2018 Sebastian Wiesner <sebastian@swsnr.de>
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

# Fish configuration of Sebastian Wiesner <sebastian@swsnr.de>

# First things first: Don't let anyone else get access to my files
umask 077

# When fish exits…
function on_exit --on-process-exit %self
    if status --is-login
        # …kill sudo timestamps if the shell is a login shell
        sudo -K
    end
end

# Paths, only for login shells
if status --is-login
    # Binaries from Python, Ruby and Rust
    set -x PATH ~/Library/Python/*/bin $PATH
    set -x PATH ~/.gem/ruby/*/bin $PATH
    set -x PATH ~/.cargo/bin $PATH

    # Binaries, manpages, etc. from ~/.local
    set -x PATH ~/.local/bin $PATH
    set -x MANPATH /usr/share/man /usr/local/share/man ~/.local/share/man
    set -x INFOPATH /usr/share/info /usr/local/share/info ~/.local/share/info
end

# Environment variables
if string match -q '*.uberspace.de' (hostname)
    # On uberspace use nano as editor
    set -x EDITOR 'nano'
else
    set -x EDITOR 'code -nw'
end

set -x PAGER 'less'
if command --search 'xdg-open' >/dev/null
    # Unix
    set -x BROWSER 'xdg-open'
else
    # macOS
    set -x BROWSER 'open'
end

# Color theme for bat, see <https://github.com/sharkdp/bat>
set -x BAT_THEME 'TwoDark'
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
set -x LESS '-q -g -i -M -R -S -w -z-4'

# Setup tools for an interactive shell
if status --is-interactive
    # Autojump for fast directory jumping
    for directory in "$HOME/share" '/usr/local/share' '/usr/share'
        if [ -f "$directory/autojump/autojump.fish" ]
            source "$directory/autojump/autojump.fish"
            break
        end
    end

    # Virtualenv helper
    if command --search 'python3' >/dev/null
        python3 -m virtualfish ^/dev/null | source
    end

    # Prefer bat over less and cat
    if command --search 'bat' >/dev/null
        alias less='bat --paging always'
        alias cat='bat --paging never'
    end

    # Prefer exa over ls for listings
    if command --search 'exa' >/dev/null
        alias ll='exa --long --git'
        alias la='ll --all'
    else
        alias ll='ls -l'
        alias la='ls -la'
    end

    # Abbreviations (unlike aliases, these are expanded before running)
    abbr --add _ sudo
    abbr --add df df -kh
    abbr --add du du -kh
    abbr --add e eval $EDITOR
    abbr --add o open
    abbr --add g git
    abbr --add pbc pbcopy
    abbr --add pbp pbpaste

    if not command --search ldd >/dev/null
        # I always forget this one on macOS
        alias ldd='otool -L'
    end

    if not command --search pbcopy >/dev/null
        # If not on macOS pretend we were
        alias pbcopy='xsel -bi'
        alias pbpaste='xsel -bo'
        alias open='xdg-open'
    end
end
