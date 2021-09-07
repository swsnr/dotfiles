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

function boulderwelt -d 'Boulderwelt Queue'
    xh -f POST 'https://www.boulderwelt-muenchen-west.de/wp-admin/admin-ajax.php' action=cxo_get_crowd_indicator |
        jq -r '@text "\(.level)%"'
end
