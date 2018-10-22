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

function rename-window -d 'Rename the current tab'
    argparse --name=rename-window 'h/help' 'c/clear' -- $argv
    or return 1

    if set -q _flag_help
        echo "rename-window --clear"
        echo "rename-window [TITLE]"
        return 0
    else if set -q _flag_clear
        set --erase fish_title
        return 0
    else if set -q argv[1]
        set -g fish_title $argv[1]
        return 0
    else
        read -P 'New window title: ' -g fish_title
    end
end
