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
    set -l mode $argv[1]
    if [ -z $mode ]
        set mode auto
    end

    set -l background
    switch $mode
        case light
            set background light
        case dark
            set background dark
        case auto
            if command -q xtermbg
                set background (xtermbg -t)
            end
            if [ -z $background[1] ]
                set background unknown
            end
        case '*'
            echo "Unknown background mode: $mode"
            return 1
    end

    # Adapt shell environment to background color
    switch $background
        case light
            set -gx BAT_THEME OneHalfLight
            set VIVID_THEME one-light
            # TODO: Perhaps find one-light for micro?
            set -gx MICRO_COLORSCHEME bubblegum
        case dark
            set -gx BAT_THEME OneHalfDark
            set VIVID_THEME one-dark
            set -gx MICRO_COLORSCHEME one-dark
        case unknown
            # If we don't know about the terminal background, default to the
            # standard 8 bit theme in Bat
            set -gx BAT_THEME ansi
    end

    # dircolors, by vidid <https://github.com/sharkdp/vivid>
    # Only if we can determine background colours, otherwise leave dircolors
    # alone.
    if command -q vivid && set -q VIVID_THEME
        set -gx LS_COLORS (vivid generate $VIVID_THEME)
    end
end
