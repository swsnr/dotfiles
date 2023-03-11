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

# Make acme.sh use XDG base dirs
function acme.sh
    set -l config_home $HOME/.config
    set -l data_home $HOME/.local/share
    if set -q XDG_CONFIG_HOME
        set config_home $XDG_CONFIG_HOME
    end
    if set -q XDG_DATA_HOME
        set data_home $XDG_DATA_HOME
    end

    set -l config_dir $config_home/acme.sh
    set -l data_dir $data_home/acme.sh
    set -l cert_dir $data_dir/certs

    mkdir --mode=0700 -p $config_dir $data_dir $cert_dir
    command acme.sh \
        --home $data_dir --config-home $config_dir --cert-home $cert_dir \
        $argv
end
