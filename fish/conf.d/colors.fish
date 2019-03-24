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

if status --is-interactive
    # See https://github.com/lunaryorn/term-background.rs
    if command --search 'term-background' >/dev/null
        set -x LY_TERM_BACKGROUND (term-background --timeout 1000 (tty))
        if string match -q light $LY_TERM_BACKGROUND
            set -x BAT_THEME 'Monokai Extended Light'
        else
            set -x BAT_THEME 'Monokai Extended'
        end
    end
end
