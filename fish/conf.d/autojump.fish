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

# Autojump for fast directory jumping
if status --is-interactive
    for directory in "$HOME/.autojump" '/usr/local' '/usr'
        set -l __autojump_file "$directory/share/autojump/autojump.fish"
        if [ -f $__autojump_file ]
            source $__autojump_file
            break
        end
        set -e __autojump_file
    end
end
