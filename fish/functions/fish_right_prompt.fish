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

function fish_right_prompt -d 'My right-hand side prompt'
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

    echo -sn (set_color white) '❮' (set_color normal)
    set -l battery (prompt_battery)
    if string length -q $battery $battery
        echo -sn ' ' $battery
    end
    echo -sn (__fish_git_prompt)
end
