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

function get -d 'Download from a remote URL'
    if command --search 'curl' >/dev/null
        curl --continue-at - --location --progress-bar --remote-name --remote-time --remote-header-name $argv
    else if command --search 'wget' >/dev/null
        wget --continue --progress=bar --timestamping $argv
    else
        echo 'Don\'t know how to download 😞'
        return 1
    end
end
