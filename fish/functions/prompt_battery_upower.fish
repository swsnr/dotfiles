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

function prompt_battery_upower -d 'upower battery info in prompt'
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

    set -l level
    set -l state_symbol
    set -l colour

    # Parse the state into a colour to use in the prompt and a state symbol
    # to indicate the battery state.
    switch $state
        case 'fully-charged'
            # Bail out if the battery is fully charged. In this case battery
            # information is really redundant, and we do not want to show
            # anything.
            return 0
        case 'charging'
            set -l time_to_full (string match -r '^time to full:\s+(.+)' $battery_info)[2]
            if test -n "$time_to_full"
                set level "|$time_to_full"
            else
                set level "|$percentage"
            end
            set colour (set_color 'green')
            set state_symbol '↑'
        case 'discharging'
            set -l time_to_empty (string match -r '^time to empty:\s+(.+)' $battery_info)[2]
            if test -n "$time_to_empty"
                set level "|$time_to_empty"
            else
                set level "|$percentage"
            end
            set -l warning_level (string match -r '^warning-level:\s+(.+)' $battery_info)[2]
            switch $warning_level
                case 'none'
                    set state_symbol '↓'
                    set colour (set_color 'yellow')
                case 'low'
                    set state_symbol '↡'
                    set colour (set_color 'red')
                case '*'
                    echo -s -n (set_color -o red) 'UNKNOWN WARNING LEVEL:' $warning_level (set_color normal)
            end
        case '*'
            echo -s -n (set_color -o red) 'UNKNOWN STATE:' $state (set_color normal)
            return 1
    end

    echo -s -n $colour $state_symbol $level (set_color normal)
end
