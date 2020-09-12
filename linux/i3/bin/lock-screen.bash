#!/bin/bash
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

# Suspend dunst first
systemctl --user kill dunst.service --signal USR1

XSECURELOCK_BLANK_TIMEOUT=5 \
    XSECURELOCK_BLANK_DPMS_STATE=suspend \
    XSECURELOCK_SHOW_DATETIME=1 \
    XSECURELOCK_DATETIME_FORMAT='%A, %Y-%m-%d %H:%M (%V)' \
    XSECURELOCK_FONT=PragmataPro \
    XSECURELOCK_PASSWORD_PROMPT=disco \
    xsecurelock

# Tell logind that the session's unlocked again
loginctl unlock-session

# Resume dunst after unlock
systemctl --user kill dunst.service --signal USR2
