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

function amm --description 'Scala REPL'
    # Launch ammonite indirectly via sh to work around the messing shebang in
    # its launcher (see https://github.com/lihaoyi/Ammonite/issues/813).  We
    # propagate arguments from this function and expand them to ammonite via $@.
    # The first argument needs to be the "command name" which is why amm appears
    # twice here.
    sh -c 'amm "$@"' amm $argv
end
