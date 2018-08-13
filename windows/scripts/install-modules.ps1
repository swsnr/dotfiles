# Copyright 2018 Sebastian Wiesner <sebastian@swsnr.de>
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

$modules = @(
    # Colourful ls
    'Get-ChildItemColor'
    # Adds git status information to powershell prompt
    'posh-git'
    # autojump for powershell: Quickly jump to directories
    'Jump.Location'
    # Better line editing for powershell
    'PSReadLine'
    # YAML support for powershell
    'powershell-yaml'
);

PowerShellGet\Install-Module $modules -Scope CurrentUser
