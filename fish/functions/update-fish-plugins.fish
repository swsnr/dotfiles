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

function update-fish-plugins -d 'Update my fish plugins'
    set -l git_dir (git -C (dirname (readlink -f (status --current-filename))) rev-parse --show-toplevel)

    set -l current_head (git -C $git_dir rev-parse HEAD)

    git -C $git_dir subtree pull --squash --prefix fish/plugins/z https://github.com/jethrokuan/z.git master
    git -C $git_dir subtree pull --squash --prefix fish/plugins/nvm/ https://github.com/jorgebucaran/nvm.fish.git main
    git -C $git_dir subtree pull --squash --prefix fish/plugins/autopair https://github.com/jorgebucaran/autopair.fish.git main
    git -C $git_dir subtree pull --squash --prefix fish/plugins/sdkman https://github.com/reitzig/sdkman-for-fish.git master
    git -C $git_dir subtree pull --squash --prefix fish/plugins/kubectl-completions https://github.com/evanlucas/fish-kubectl-completions.git main

    git -C $git_dir diff $current_head HEAD -- fish/plugins/
end
