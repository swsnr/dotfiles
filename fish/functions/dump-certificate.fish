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

function dump-certificate -d 'Dump a remote certificate'
    set -l server_name $argv[1]
    set -l server_port 443
    if set -q $argv[2]
        set server_port $argv[2]
    end
    echo |
        openssl s_client -showcerts -servername $server_name -connect $server_name:$server_port 2>/dev/null |
        openssl x509 -inform pem -noout -text
end
