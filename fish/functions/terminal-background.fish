# Copyright 2020 Sebastian Wiesner <sebastian@swsnr.de>
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

function terminal-background --description 'Get terminal background info'
    if test -x ~/.local/bin/xtermbg
        set -l response (~/.local/bin/xtermbg)
        # Ideally we'd check the exit code here, but xtermcontrol always exists zero,
        # see https://github.com/JessThrysoee/xtermcontrol/issues/13
        #
        # However in case of error we get an empty response so we can just go
        # ahead and try to extract RGB from it
        set -l rgb (string match -r '^rgb:([^/]{2})[^/]*/([^/]{2})[^/]*/([^/]{2})[^/]*$' $response)
        if set -q rgb[1]
            # Remove the first group; it contains the entire matched string but
            # we only need the groups.  Matches now contains an r g b array
            set -e rgb[1]

            # Derive luminance from RGB, as per ITU-R BT.709, 3 Signal format, item 3.2
            # We prefix each part of the array with 0x because the values are hex
            set -l luminance (math 0x$rgb[1] x 0.2126 + 0x$rgb[2] x 0.7152 + 0x$rgb[3] x 0.0722)

            if test 128 -lt $luminance
                echo light
            else
                echo dark
            end
            return 0
        end
    end

    # We haven't been able to figure out the background color
    return 1
end
