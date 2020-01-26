# Copyright 2019 Sebastian Wiesner <sebastian@swsnr.de>
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

function op-copy --description 'Copy a password from 1Password'
    if ! set -q argv[1]
        echo "Item name required" 2>&1
        return 1
    end

    set -l item $argv[1]

    op get item $item |
    jq -r '.details.fields[] | (select(.designation == "password") // select(.name == "password")) | .value' |
    wl-copy --paste-once
end
