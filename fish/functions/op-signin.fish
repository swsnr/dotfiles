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
    if not set -q OP_ACCOUNT_SHORTHAND
        echo '1Password account not set; export $OP_ACCOUNT_SHORTHAND'
        return 1
    end
    set -l session_var OP_SESSION_$OP_ACCOUNT_SHORTHAND
    if not set -q $session_var
        eval (op signin --account swsnr)
    else
        # Ensure the session is still valid and refresh it otherwise
        eval (op signin --session $$session_var)
    end
end
