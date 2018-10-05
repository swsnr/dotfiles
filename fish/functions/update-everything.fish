# Copyright 2018 Sebastian Wiesner <sebastian@swsnr.de>
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

function update-everything -d "Update all my stuff"
    if string match --quiet 'darwin*' $OSTYPE
        echo -s (set_color -o) 'Updating homebrew' (set_color normal)
        brew upgrade
    end

    if command --search apt-get >/dev/null
        echo -s (set_color -o) 'Update APT packages' (set_color normal)
        sudo apt-get update
        sudo apt-get upgrade
    end

    echo -s (set_color -o) 'Update Rust packages' (set_color normal)
    cargo install-update --all

    if command --search tlmgr >/dev/null
        echo -s (set_color -o) 'Update all Texlive packages' (set_color normal)
        sudo tlmgr update --self --all
    end
end
