# Copyright 2020 Sebastian Wiesner <sebastian@swsnr.de>
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

function update-theme -d 'Read the current terminal background and update our environment'
    # Detect terminal background color and adapt color themes accordingly.
    set -gx LY_TERM_BACKGROUND (terminal-background)

    if [ -z $LY_TERM_BACKGROUND ]
        set -gx LY_TERM_BACKGROUND 'unknown'
    end

    # Adapt shell environment to background color
    if string match -q light $LY_TERM_BACKGROUND
        set -gx BAT_THEME 'Solarized (light)'
        set VIVID_THEME 'ayu'
    else
        set -gx BAT_THEME 'Solarized (dark)'
        set VIVID_THEME 'molokai'
    end

    # dircolors, by vidid <https://github.com/sharkdp/vivid>
    if command -q vivid
        set -gx LS_COLORS (vivid generate $VIVID_THEME)
    end
end
