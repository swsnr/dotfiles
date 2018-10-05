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

# Personal prompt of Sebastian Wiesner <sebastian@swsnr.de>
#
# Features iTerm integration, command exit status, sudo and SSH support, working
# directory, virtualenv, battery information and git status.

function fish_prompt -d 'My personal prompt'
    # Indicate exit code of last command
    if test $status -eq 0
        echo -sn (set_color green) '✔'
    else
        echo -sn (set_color -o red) '!'
    end
    echo -sn (set_color normal)
    if set -q SUDO_USER
        # Show the target user name when in a sudo shell
        echo -sn ' ' (set_color -o red) $USER (set_color normal)
    else if set -q SSH_CONNECTION
        # When connected via SSH show the login user name
        echo -sn ' ' (set_color magenta) $USER (set_color normal)
    end
    if set -q SSH_CONNECTION
        # When connected via SSH show the target system
        echo -sn '@' (set_color magenta) (prompt_hostname) (set_color normal)
    end
    # Working directory
    echo -sn ' ' (set_color cyan) (prompt_pwd) (set_color normal)
    # Python virtualenv if any
    if set -q VIRTUAL_ENV
        echo -sn ' (' (set_color -i cyan) (basename $VIRTUAL_ENV) (set_color normal) ')'
    end
    # Prompt separator
    echo -sn (set_color green) ' ❯ ' (set_color normal)
    # Tell iterm that the command input starts now
    iterm2_command 'command_start'
end
