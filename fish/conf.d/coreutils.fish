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

# Improve coreutils by aliases and replacing with better alternatives

if status --is-interactive
    # Prefer bat over less and cat
    if command --search 'bat' >/dev/null
        alias less='bat --paging always'
        alias cat='bat --paging never'
    end

    # Prefer exa over ls for listings
    if command --search 'exa' >/dev/null
        alias ll='exa --long --git'
        alias la='ll --all'
    else
        alias ll='ls -l'
        alias la='ls -la'
    end
end
