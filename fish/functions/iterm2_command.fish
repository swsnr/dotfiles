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

# See https://iterm2.com/documentation-escape-codes.html for escape codes
function iterm2_command -d 'Run an escape code command for iterm2'
    set -l command $argv[1]
    set -l args
    if [ (count $argv) -gt 1 ]
        set args $argv[2..-1]
    else
        set args []
    end
    switch $command
        case 'prompt'
            ftcs_escape_code 'A'
        case 'command_start'
            ftcs_escape_code 'B'
        case 'command_executed'
            ftcs_escape_code 'C'
        case 'command_finished'
            if [ (count $args) -eq 0 ]
                ftcs_escape_code 'D'
            else
                ftcs_escape_code (printf 'D;%s' $args)
            end
        case 'current_dir'
            iterm2_escape_code (printf 'CurrentDir=%s' $args)
        case 'remote_host'
            iterm2_escape_code (printf 'RemoteHost=%s@%s' $args)
        case '*'
            echo 'Unknown command', $command
            return 1
    end
end
