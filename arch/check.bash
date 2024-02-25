#!/bin/bash
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

set -xeuo pipefail

# Check the general state of the system, in the last three days

# Three days
two_weeks_s=259200
now_s="$(date --utc '+%s')"
two_weeks_ago="$((now_s - two_weeks_s))"
# Convert to timestamp and cut of timezone offset. It's zero anyways.
# Then replace T with a space, because that's the format systemd wants
last_check_timestamp="$(date -d@"${two_weeks_ago}" +'%Y-%m-%d %T')"
echo "Checking events since ${last_check_timestamp}"

# List failed units, new coredumps, and journalctl
systemctl --failed
coredumpctl --no-pager --since="${last_check_timestamp}" list || true
journalctl --no-pager -p3 --since="${last_check_timestamp}"
