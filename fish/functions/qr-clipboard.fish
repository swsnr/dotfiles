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

function qr-clipboard -d 'Encode clipboard contents to a QR code'
    switch $TERM
        case wezterm
            wl-paste | qrencode --size 12 --output - | wezterm imgcat
        case '*'
            printf "Terminal %s cannot display images\n" $TERM 1>&2
            return 1
    end
end