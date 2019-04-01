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

function prompt_battery_macos -d 'macOS Battery info in prompt'
    set -l battery_status (pmset -g batt)

    # Pattern to extract battery information from pmset -g.  We match three
    # groups:
    #
    # 1. The load level as percentage
    # 2. The state up to the next separator ; (e.g. "charged" or "AC attached")
    # 3. The remaining time
    set -l pattern '^\\s+-InternalBattery-\\d+? \\(.+?\\)\\s+(\\d+)%;\\s+([^;]+);\\s+(.+?)\\s+present: true$'
    set -l matches (string match -r $pattern $battery_status)
    # Bail out early with a big fat debug message if we failed to parse the
    # battery information, to make me debug the thing.
    if test (count $matches) -le 0
        echo -s -n (set_color -o red) 'NO PARSE FROM pmset -g batt' (set_color normal)
        return 1
    end

    # Take the matches apart.  $matches[1] is the entire text matched by the
    # whole regex, so we start at 2 for the 1st matching group.
    set -l percentage $matches[2]
    set -l state $matches[3]
    set -l remaining $matches[4]

    # Try to parse the actual hours and minutes out of the remaining time
    # estimate to include them in the prompt. Fall back to the precentage
    # level if the system can't provide any estimation of the remaining time
    set -l time (string match -r '\\d+:\\d+' $remaining)
    if test (count $time) -gt 0
        set level "|$time[1]"
    else
        set level "|$percentage%"
    end

    # Parse the state into a colour to use in the prompt and a state symbol
    # to indicate the battery state.
    switch $state
        case 'charged'
            # Bail out if the battery is fully charged. In this case battery
            # information is really redundant, and we do not want to show
            # anything.
            return 0
        case 'finishing charge'
            # Likewise if the battery is about to be fully charged any moment
            return 0
        case 'AC attached'
            # A special state when the AC adapter is freshly plugged but macOS
            # hasn't yet started to charge the battery
            set colour (set_color 'green')
            set state_symbol '-'
        case 'charging'
            set colour (set_color 'green')
            set state_symbol '↑'
        case 'discharging'
            # When the battery is discharging check the output again for
            # a potential warning about low battery level
            set -l matches (string match -r 'Battery Warning: (\\S+)' $battery_status)
            if test (count $matches) -gt 0
                switch $matches[2]
                    case 'Early'
                        set state_symbol '↡'
                        set colour (set_color 'red')
                    case '*'
                        # "Final" or something maybe even worse \o/
                        set state_symbol '↡'
                        set colour (set_color -b 'red' -o 'white')
                end
            else
                set state_symbol '↓'
                set colour (set_color 'yellow')
            end
        case *
            echo -s -n (set_color -o red) 'UNKNOWN STATE:' $state (set_color normal)
            return 1
    end

    echo -s -n $colour $state_symbol $level (set_color normal)
end
