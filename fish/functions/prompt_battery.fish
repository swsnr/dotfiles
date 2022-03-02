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

function prompt_battery -d 'Battery information for prompt'
    set -l battery_info
    set -l battery_info_start_index

    for device in (upower -e)
        set battery_info (string trim (upower -i $device))
        set battery_info_start_index (contains -i battery $battery_info)
        if test $status -eq 0
            set battery_info $battery_info[$battery_info_start_index..(count $battery_info)]
        else
            set battery_info
            set battery_info_start_index
        end
    end

    # Take the matches apart.  $matches[1] is the entire text matched by the
    # whole regex, so we start at 2 for the 1st matching group.
    set -l percentage (string match -r '^percentage:\s+(.+)' $battery_info)[2]
    set -l state (string match -r '^state:\s+(.+)' $battery_info)[2]

    # The stepwise level, as a number between 0 and 10.
    set -l stepwise_level (math 'floor(' (string replace '%' '' $percentage) / 10 ')')

    set -l level
    set -l state_symbol
    set -l colour

    switch $state
        case fully-charged
            set state_symbol '\uf573'
            set colour 'green'
        case charging
            set -l time_to_full (string match -r '^time to full:\s+(.+)' $battery_info)[2]
            if test -n "$time_to_full"
                set level " $time_to_full"
            else
                set level " $percentage"
            end

            set colour 'green'
            # Nerd fonts fucked up the charging icons, see https://github.com/ryanoasis/nerd-fonts/issues/279
            # Icons for 10%, 50% and 70% are missing, but for whatever insane
            # reason 30% exists, so we cannot compute an icon elegantly either
            # for 10 or 20% steps, so we use 20% steps and just write everything
            # out 😒
            switch $stepwise_level
                case 0
                    set state_symbol '\uf585'
                case 1 2
                    set state_symbol '\uf585'
                case 3
                    set state_symbol '\uf586'
                case 4 5
                    set state_symbol '\uf587'
                case 6 7
                    set state_symbol '\uf588'
                case 8
                    set state_symbol '\uf589'
                case 9
                    set state_symbol '\uf58a'
                case 10
                    set state_symbol '\uf584'
            end
        case discharging
            set -l time_to_empty (string match -r '^time to empty:\s+(.+)' $battery_info)[2]
            if test -n "$time_to_empty"
                set level " $time_to_empty"
            else
                set level " $percentage"
            end

            if test $stepwise_level -eq 0
                set state_symbol '\uf582'
                set colour -b 'red' -o 'white'
            else if test $stepwise_level -eq 10
                set state_symbol '\uf578'
            else
                set state_symbol (string replace '0x' '\u' (math --base hex 0xf578 + $stepwise_level))
            end

            set -l warning_level (string match -r '^warning-level:\s+(.+)' $battery_info)[2]
            switch $warning_level
                case none
                    set colour 'green'
                case low
                    set colour 'yellow'
                case critical
                    set state_symbol '\uf582'
                    set colour -b 'red' -o 'white'
                case '*'
                    set colour -b 'red'
                    set state_symbol '\uf590'
            end
        case '*'
            set level UNKNOWN
            set colour -o red
            set state_symbol '\uf590'
    end
    printf '%s%b%s%s' (set_color $colour) $state_symbol $level (set_color normal)
end
