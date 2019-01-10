# Copyright 2019 Sebastian Wiesner <sebastian@swsnr.de>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if (-Not (Get-Command "scoop" -errorAction SilentlyContinue)) {
    # Install scoop if not already present
    Invoke-Expression (New-Object Net.WebClient).DownloadString('https://get.scoop.sh')
}

# Buckets
scoop bucket add java
scoop bucket add lunaryorn https://github.com/lunaryorn/scoop-bucket.git

$packages = (
    # Basic tools
    "git",
    "python",
    "ripgrep",
    "tokei",
    "mdcat",

    # Data processing
    "jq",
    "xsv",

    # Java & Scala packages
    "zulu8",
    "sbt",
    "ammonite",

    # Misc tools for programming
    "shellcheck"
)

# Install packages
scoop install $packages
