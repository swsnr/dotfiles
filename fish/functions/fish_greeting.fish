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

function fish_greeting -d 'My cow says things to you!'
    if not command -q cowsay
        echo 'I am silent. Install cowsay!'
        return 1
    end
    if not command -q fortune
        cowsay -y 'I have nothing to say. Install fortune!'
        echo
        return 1
    end

    # -s gives me just a short story; don't want to read a novel whenever
    # I start a shell
    cow-fortune -s
    echo
end
