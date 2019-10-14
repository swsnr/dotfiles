# Copyright 2018-2019 Sebastian Wiesner <sebastian@swsnr.de>
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

# Powershell profile for all hosts.

# Locale for unix programs if not already present
if (-not (Test-Path env:LC_ALL)) {
    $env:LC_ALL = 'en_GB.utf8'
}

function Get-AbbreviatedPath([String] $path) {
    <#
    .SYNOPSIS
    Abbreviates a path.

    .DESCRIPTION
    Abbreviates the given path by shortening all leading path segments to their
    first character, leaving only the leaf at full length.

    .PARAMETER path
    The path to shorten.  Mandatory
    #>

    if ($path.Length -eq 0) {
        return $path;
    }

    $head = Split-Path $path

    if ($head) {
        $leaf = Split-Path $path -Leaf
        $separator = [IO.Path]::DirectorySeparatorChar.ToString()
        $removeEmpty = [System.StringSplitOptions]::RemoveEmptyEntries
        $abbreviatedParts = $head.split($separator, $removeEmpty) | ForEach-Object { $_.substring(0, 1) }

        if ($abbreviatedParts.Length -eq 0) {
            $abbreviated = $leaf
        }
        else {
            $abbreviated = ($abbreviatedParts -join $separator) | Join-Path -ChildPath $leaf
        }

        if ($path.StartsWith($separator)) {
            return $separator + $abbreviated
        }
        else {
            return $abbreviated
        }
    }
    else {
        return $path;
    }
}

function ConvertTo-TotalHours ([int] $minutes) {
    <#
     .SYNOPSIS
     Converts minutes to total hours.

     .DESCRIPTION
     Converts the given minutes to the corresponding total hours value, rounded
     to two decimals.

     .PARAMETER minutes
     The minutes to convert. Mandatory.
    #>
    return '{0:0.##}' -f [System.TimeSpan]::FromMinutes($minutes).TotalHours
}


# Fancy prompt for console hosts
Import-Module posh-git

# Replace home with ~
$GitPromptSettings.DefaultPromptPath.ForegroundColor = [ConsoleColor]::DarkMagenta
$GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true;
$GitPromptSettings.DefaultPromptBeforeSuffix.Text = "`n";
$GitPromptSettings.DefaultPromptSuffix.Text = '→ '
$GitPromptSettings.DefaultPromptSuffix.ForegroundColor = [ConsoleColor]::White;
$GitPromptSettings.DefaultPromptPrefix.Text = 'In ';
$GitPromptSettings.DefaultPromptPrefix.ForegroundColor = [ConsoleColor]::White
$GitPromptSettings.BeforeStatus.Text = 'on  '
$GitPromptSettings.BeforeStatus.ForegroundColor = [ConsoleColor]::White
$GitPromptSettings.AfterStatus.Text = ''
$GitPromptSettings.BranchIdenticalStatusSymbol.ForegroundColor = [ConsoleColor]::DarkGreen
$GitPromptSettings.BranchColor.ForegroundColor = [ConsoleColor]::DarkCyan
$GitPromptSettings.DelimStatus.ForegroundColor = [ConsoleColor]::White
$GitPromptSettings.WorkingColor.ForegroundColor = [ConsoleColor]::DarkMagenta
$GitPromptSettings.LocalStagedStatusSymbol = '●'
$GitPromptSettings.LocalWorkingStatusSymbol = '+'
$GitPromptSettings.LocalWorkingStatusSymbol.ForegroundColor = [ConsoleColor]::DarkYellow

# Jump to directories fast. Import _after_ posh-git to make sure that location
# tracking works, see <https://github.com/vors/ZLocation#note>
Import-Module ZLocation
New-Alias -Name j -Value z

# Unixification
New-Alias -Name which -Value Get-Command

# Coloured ls
Import-Module Get-ChildItemColor
New-Alias -Name ll -Value Get-ChildItemColor

# Git aliases
New-Alias -Name g -Value "git" -Option AllScope

function Set-LocationGitRoot {
    Set-Location (git root)
}

New-Alias -Name gcd -Value "Set-LocationGitRoot"

# Script aliases
function apod {
    py ${env:userprofile}/.dotfiles/bin/apod $args
}

# Load machine-specific settings
function Invoke-LocalProfile {
    $local_profile = Join-Path (Split-Path $profile.CurrentUserAllHosts) 'local.ps1'
    if (Test-Path $local_profile) {
        . $local_profile;
    }
}

Invoke-LocalProfile

# Add custom type data
Update-TypeData -AppendPath (Join-Path (Split-Path $profile.CurrentUserAllHosts) -ChildPath 'types.ps1xml')

# Source local completion scripts
. (Join-Path (Split-Path $profile.CurrentUserAllHosts) '_rg.ps1')
