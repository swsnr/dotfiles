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

function dump_env_posix -d 'Dump important environment variables for POSIX sh'
    set -l variables \
        EDITOR \
        BROWSER \
        PAGER \
        PATH \
        http_proxy https_proxy no_proxy \
        HTTP_PROXY HTTPS_PROXY NO_PROXY \
        JAVA_OPTS \
        QT_QPA_PLATFORMTHEME \
        QT_QPA_PLATFORM \
        MOZ_ENABLE_WAYLANDF

    for variable in $variables
        if set -q $variable
            echo "$variable='$$variable'"
            echo "export $variable"
        end
    end
end
