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

function fish_prompt -d 'My personal prompt'
    set -l last_exit_code $status

    # Settings for the Git prompt
    set -g __fish_git_prompt_show_informative_status 1
    set -g __fish_git_prompt_hide_untrackedfiles 1

    set -g __fish_git_prompt_color_branch -o magenta
    set -g __fish_git_prompt_showupstream "informative"
    set -g __fish_git_prompt_char_upstream_prefix ""

    set -g __fish_git_prompt_color_dirtystate red
    set -g __fish_git_prompt_color_stagedstate yellow
    set -g __fish_git_prompt_color_invalidstate red
    set -g __fish_git_prompt_color_untrackedfiles red
    set -g __fish_git_prompt_color_cleanstate green

    if [ (id -u) -eq 0 ] || set -q SSH_CONNECTION
        set -l color 'yellow'
        if [ $USER = 'root' ]
            set color 'red'
        end
        echo -sn (set_color -o $color) $USER (set_color -o normal)

        if set -q SSH_CONNECTION
            echo -sn '@' (set_color -o green) (prompt_hostname) (set_color -o normal) ' in '
        else
            echo ' in '
        end
    end
    # Working directory and git prompt
    echo -sn (set_color -o cyan) (prompt_pwd) (set_color normal)
    echo -sn (set_color -o) (__fish_git_prompt " on  %s")

    # Python virtualenv if any
    if set -q VIRTUAL_ENV
        echo -sn (set_color -o) ' via ' (set_color -o cyan) (basename $VIRTUAL_ENV) (set_color normal)
    end

    # Time
    echo -sn (set_color -o) ' at ' (set_color -o cyan) (date '+%H:%M') (set_color normal)
    if command -q wcal && test 120 -le $COLUMNS
        # And a small week calender if terminal size permits
        echo -sn ' (' (wcal -cC | tail -n1) ')'
    end

    # Battery if present and supported
    set -l battery (prompt_battery)
    if string length -q $battery $battery
        echo -sn (set_color -o) ' ⚡' $battery
    end

    # New line
    echo -s

    echo -sn (fish_default_mode_prompt)

    # Private mode
    if set -q fish_private_mode
        echo -sn (set_color -o red) "⦸" (set_color normal) ' '
    end

    # Indicate exit code of last command
    if test $last_exit_code -eq 0
        echo -sn (set_color -o green)
    else
        echo -sn (set_color -o red)
    end
    echo -sn "→ " (set_color normal)
end
