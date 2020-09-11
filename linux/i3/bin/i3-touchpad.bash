#!/bin/bash
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

set -e

touchpad="$(xinput list --name-only | grep -i touchpad)"
props="$(xinput list-props "${touchpad}")"

set-prop() {
    local property="$1"
    shift
    if [[ "$props" == *"$property"* ]]; then
        xinput set-prop "$touchpad" "$property" "$@"
    else
        echo "Skipping $property, does not exist" 1>&2
    fi
}

# Enable natural scrolling
set-prop 'libinput Natural Scrolling Enabled' 1
# Use multi-finger click instead of buttons
set-prop 'libinput Click Method Enabled' 0 1
