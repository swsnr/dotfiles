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
    if not command -q upower
        return
    end

    set -l battery_info
    set -l battery_info_start_index

    for device in (upower -e)
        set battery_info (string trim (env LC_NUMERIC=C upower -i $device))
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

    set -l nf_md_battery '\Uf0079'
    set -l nf_md_battery_unknown '\Uf0091'
    set -l nf_md_battery_alert '\Uf0083'
    set -l nf_md_battery_charging_high '\Uf12a6'
    set -l nf_md_battery_10 '\Uf007a'
    set -l nf_md_battery_20 '\Uf007b'
    set -l nf_md_battery_30 '\Uf007c'
    set -l nf_md_battery_40 '\Uf007d'
    set -l nf_md_battery_50 '\Uf007e'
    set -l nf_md_battery_60 '\Uf007f'
    set -l nf_md_battery_70 '\Uf0080'
    set -l nf_md_battery_80 '\Uf0081'
    set -l nf_md_battery_90 '\Uf0082'
    set -l nf_md_battery_charging_10 '\Uf089cf089c'
    set -l nf_md_battery_charging_20 '\Uf0086'
    set -l nf_md_battery_charging_30 '\Uf0087'
    set -l nf_md_battery_charging_40 '\Uf0088'
    set -l nf_md_battery_charging_50 '\Uf089d'
    set -l nf_md_battery_charging_60 '\Uf0089'
    set -l nf_md_battery_charging_70 '\Uf089e'
    set -l nf_md_battery_charging_80 '\Uf008a'
    set -l nf_md_battery_charging_90 '\Uf008b'
    set -l nf_md_battery_charging_100 '\Uf0085'

    switch $state
        case fully-charged
            set state_symbol $nf_md_battery_charging_high
            set colour green
        case charging
            set -l time_to_full (string match -r '^time to full:\s+(.+)' $battery_info)[2]
            if test -n "$time_to_full"
                set level " $time_to_full"
            else
                set level " $percentage"
            end

            set colour green
            # Nerd fonts messed up the charging icons: Charging 10 comes before charging 100, and charging 20 comes after
            # so we'll need to fiddle a bit
            switch $stepwise_level
                case 0 1
                    set state_symbol $nf_md_battery_charging_10
                case 2
                    set state_symbol $nf_md_battery_charging_20
                case 3
                    set state_symbol $nf_md_battery_charging_30
                case 4
                    set state_symbol $nf_md_battery_charging_40
                case 5
                    set state_symbol $nf_md_battery_charging_50
                case 6
                    set state_symbol $nf_md_battery_charging_60
                case 7
                    set state_symbol $nf_md_battery_charging_70
                case 8
                    set state_symbol $nf_md_battery_charging_80
                case 9
                    set state_symbol $nf_md_battery_charging_90
                case 10
                    set state_symbol $nf_md_battery_charging_100
                case '*'
                    set state_symbol $nf_md_battery_unknown
            end
        case discharging
            set -l time_to_empty (string match -r '^time to empty:\s+(.+)' $battery_info)[2]
            if test -n "$time_to_empty"
                set level " $time_to_empty"
            else
                set level " $percentage"
            end

            switch $stepwise_level
                case 0
                    set state_symbol $nf_md_battery_alert
                    set colour -b red -o white
                case 1
                    set state_symbol $nf_md_battery_10
                case 2
                    set state_symbol $nf_md_battery_20
                case 3
                    set state_symbol $nf_md_battery_30
                case 4
                    set state_symbol $nf_md_battery_40
                case 5
                    set state_symbol $nf_md_battery_50
                case 6
                    set state_symbol $nf_md_battery_60
                case 7
                    set state_symbol $nf_md_battery_70
                case 8
                    set state_symbol $nf_md_battery_80
                case 9
                    set state_symbol $nf_md_battery_90
                case 10
                    set state_symbol $nf_md_battery
                case '*'
                    set state_symbol $nf_md_battery_unknown
            end

            set -l warning_level (string match -r '^warning-level:\s+(.+)' $battery_info)[2]
            switch $warning_level
                case none
                    set colour green
                case low
                    set colour yellow
                case critical
                    set state_symbol $nf_md_battery_alert
                    set colour -b red -o white
                case '*'
                    set colour -b red
                    set state_symbol $nf_md_battery_unknown
            end
        case '*'
            set level UNKNOWN
            set colour -o red
            set state_symbol $nf_md_battery_unknown
    end
    printf '%s%b%s%s' (set_color $colour) $state_symbol $level (set_color normal)
end
