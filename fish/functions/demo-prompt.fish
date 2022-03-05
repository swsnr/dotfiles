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

function demo-prompt -d 'Switch to a simple prompt for demo purposes'
    # Disable the right-hand side prompt and the separate mode prompt
    function fish_right_prompt
    end

    function fish_mode_prompt
    end

    function fish_prompt -d 'Simple demo prompt'
        switch $fish_bind_mode
            case insert
                set_color --background green --bold white
            case replace-one
                set_color --background green --bold white

            case visual
                set_color --background magenta white
            case default
                set_color --background red white
        end
        echo -n '$'
        set_color normal
        echo -n ' '
        printf "\033]133;B\007"
    end
end
