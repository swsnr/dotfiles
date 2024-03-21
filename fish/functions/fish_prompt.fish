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

    set -l nf_md_source_branch '\Uf062c'
    set -l nf_md_language_python '\Uf0320'
    set -l nf_md_lock '\Uf033e'

    # Mark end of last command and start of prompt
    # See https://gitlab.freedesktop.org/Per_Bothner/specifications/blob/master/proposals/semantic-prompts.md
    printf "\e]133;P;k=i\a"

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
    printf "%s%s%s%s at %s%s%s" (set_color cyan) (prompt_pwd) (set_color normal) \
        (fish_git_prompt " on $nf_md_source_branch %s") \
        (set_color cyan) (date '+%H:%M') (set_color normal)

    # Python virtualenv if any
    if set -q VIRTUAL_ENV
        printf ' %s%b@%s%s' (set_color cyan) $nf_md_language_python (realpath --relative-to=$PWD $VIRTUAL_ENV) (set_color normal)
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
        printf '%s%b%s ' (set_color red) $nf_md_lock (set_color normal)
    end

    # Indicate exit code of last command
    if test $last_exit_code -eq 0
        echo -sn (set_color green)
    else
        echo -sn (set_color red)
    end
    printf "→ %b\e]133;B\a" (set_color normal)
end
