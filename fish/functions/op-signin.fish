# Copyright Sebastian Wiesner <sebastian@swsnr.de>
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

function op-signin -d 'Signin to 1Password'
    set -l uuid (op account list --format json |
        jq -r '.[] | select(.email == $EMAIL) | .user_uuid' --arg EMAIL $EMAIL)
    if test -z $uuid
        echo 'UUID not found for' $EMAIL 1>&2
        return 1
    end

    set -l session_var OP_SESSION_$uuid

    if set -q $session_var
        eval (op signin --session $$session_var)
    else
        eval (op signin --account $uuid)
    end
end
