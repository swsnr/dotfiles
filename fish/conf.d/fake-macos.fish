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

# Make macOS and Linux more alike

if status --is-interactive
    if not command --search ldd >/dev/null
        # I always forget this one on macOS
        alias ldd='otool -L'
    end

    if not command --search pbcopy >/dev/null
        # If not on macOS pretend we were
        alias pbcopy='xsel -bi'
        alias pbpaste='xsel -bo'
        alias open='xdg-open'
    end
end
