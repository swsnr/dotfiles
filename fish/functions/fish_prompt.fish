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
    set -g __fish_git_prompt_showupstream informative
    set -g __fish_git_prompt_char_upstream_prefix ""

    set -g __fish_git_prompt_color_dirtystate red
    set -g __fish_git_prompt_color_stagedstate yellow
    set -g __fish_git_prompt_color_invalidstate red
    set -g __fish_git_prompt_color_untrackedfiles red
    set -g __fish_git_prompt_color_cleanstate green

    if [ (id -u) -eq 0 ] || set -q SSH_CONNECTION
        set -l color yellow
        if [ $USER = root ]
            set color red
        end
        echo -sn (set_color $color) $USER (set_color normal)

        if set -q SSH_CONNECTION
            echo -sn '@' (set_color green) (prompt_hostname) (set_color normal) ' in '
        else
            echo ' in '
        end
    end
    # Working directory and git prompt
    echo -sn (set_color cyan) (prompt_pwd) (set_color normal)
    echo -sn (fish_git_prompt " on  %s")

    # Time
    echo -sn ' at ' (set_color cyan) (date '+%H:%M') (set_color normal)

    # Current kubectl context if there are multiple
    if command -q kubectl
        set -l contexts (kubectl config get-contexts -oname)
        if [ 1 -lt (count $contexts) ]
            echo -sn ' k8s:' (set_color cyan) (kubectl config current-context) (set_color normal)
        end
    end

    # Python virtualenv if any
    if set -q VIRTUAL_ENV
        printf ' %s%b%s%s' (set_color cyan) '\uf81f@' (realpath --relative-to=$PWD $VIRTUAL_ENV) (set_color normal)
    end

    if command -q vboxmanage
        set -l no_vms (vboxmanage list runningvms | wc -l)
        if test $no_vms -gt 0
            printf ' %s%b%s%s' (set_color cyan) '\uf98a' $no_vms (set_color normal)
        end
    end

    # Battery if present and supported
    set -l battery (prompt_battery)
    if string length -q $battery $battery
        echo -sn ' ' $battery
    end

    # New line
    echo -s

    # Toolbox?
    if inside-toolbox
        echo -sn (set_color magenta) '⬢ ' (set_color normal)
    end

    echo -sn (fish_default_mode_prompt)

    # Private mode
    if set -q fish_private_mode
        printf '%s%b%s ' (set_color red) '\uf023' (set_color normal)
    end

    # Indicate exit code of last command
    if test $last_exit_code -eq 0
        echo -sn (set_color green)
    else
        echo -sn (set_color red)
    end
    echo -sn "→ " (set_color normal)
end
