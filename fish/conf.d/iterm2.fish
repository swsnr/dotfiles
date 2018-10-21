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

if begin
        status --is-interactive
        and string match --quiet 'iTerm*' $TERM_PROGRAM
    end
    set iterm2_hostname (hostname -f)
    function update_iterm2_location --on-event fish_prompt
        # Tell item what directory, what host we're on, and that the prompt is
        # about to begin
        iterm2_command 'current_dir' (pwd)
        iterm2_command 'remote_host' $USER $iterm2_hostname
        iterm2_command 'prompt'
    end

    function update_iterm2_exit_status --on-event fish_postexec
        # Tell iterm2 the exit code of the last command
        iterm2_command 'command_finished' $status
    end

    update_iterm2_location
end
