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

# Personal prompt of Sebastian Wiesner <sebastian@swsnr.de>
#
# Features iTerm integration, command exit status, sudo and SSH support, working
# directory, virtualenv, battery information and git status.

function fish_prompt -d 'My personal prompt'
    set -l last_exit_code $status

    # Settings for the Git prompt
    set -g __fish_git_prompt_show_informative_status 1
    set -g __fish_git_prompt_hide_untrackedfiles 1

    set -g __fish_git_prompt_color_branch -o magenta
    set -g __fish_git_prompt_showupstream "informative"
    set -g __fish_git_prompt_char_upstream_ahead "↑"
    set -g __fish_git_prompt_char_upstream_behind "↓"
    set -g __fish_git_prompt_char_upstream_prefix ""

    set -g __fish_git_prompt_char_stagedstate "●"
    set -g __fish_git_prompt_char_dirtystate "+"
    set -g __fish_git_prompt_char_untrackedfiles "…"
    set -g __fish_git_prompt_char_conflictedstate "x"
    set -g __fish_git_prompt_char_cleanstate "✔"

    set -g __fish_git_prompt_color_dirtystate red
    set -g __fish_git_prompt_color_stagedstate yellow
    set -g __fish_git_prompt_color_invalidstate red
    set -g __fish_git_prompt_color_untrackedfiles red
    set -g __fish_git_prompt_color_cleanstate green

    echo -sn '('
    if set -q SUDO_USER
        echo -sn (set_color -o red) $USER (set_color normal)
    else
        echo -sn (set_color magenta) $USER (set_color normal)
    end
    echo -sn '@' (set_color magenta) (prompt_hostname) (set_color normal) ')'

    # Working directory and git prompt
    echo -sn ' (' (set_color cyan) (prompt_pwd) (set_color normal) ')'
    echo -sn (__fish_git_prompt)

    # Battery if present and supported
    set -l battery (prompt_battery)
    if string length -q $battery $battery
        echo -sn ' (' $battery ')'
    end

    # Python virtualenv if any
    if set -q VIRTUAL_ENV
        echo -sn ' (' (set_color -i cyan) (basename $VIRTUAL_ENV) (set_color normal) ')'
    end
    echo -s
    # Indicate exit code of last command
    if test $last_exit_code -eq 0
        echo -sn (set_color green) '✔'
    else
        echo -sn (set_color -o red) !
    end
    echo -sn (set_color normal)

    set -l flags
    if set -q fish_private_mode
        set -a flags 'private'
    end
    if set -q SUDO_USER
        set -a flags 'sudo'
    end
    if set -q SSH_CONNECTION
        set -a flags 'ssh'
    end
    if [ 0 -lt (count $flags) ]
        echo -sn ' ' (set_color -o yellow) (string join ' ' $flags) (set_color normal)
    end

    # Add fish mode to prompt right before separator
    echo -sn ' ' (fish_default_mode_prompt)

    # Prompt separator
    echo -sn (set_color green) '❯ ' (set_color normal)
    # Tell iterm that the command input starts now
    iterm2_command 'command_start'
end
