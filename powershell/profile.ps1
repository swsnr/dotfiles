# CCopyright 2018-2019 Sebastian Wiesner <sebastian@swsnr.de>
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
        $abbreviatedParts = $head.split($separator, $removeEmpty) |
            ForEach-Object { $_.substring(0, 1) }

        if ($abbreviatedParts.Length -eq 0) {
            $abbreviated = $leaf
        }
        else {
            $abbreviated = ($abbreviatedParts -join $separator) |
                Join-Path -ChildPath $leaf
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

function Get-PromptWorkingDir {
    # Adapted from Get-PromptPath, see https://github.com/dahlbyk/posh-git/blob/master/src/Utils.ps1#L290

    # A UNC path has no drive so it's better to use the ProviderPath e.g. "\\server\share".
    # However for any path with a drive defined, it's better to use the Path property.
    # In this case, ProviderPath is "\LocalMachine\My"" whereas Path is "Cert:\LocalMachine\My".
    # The latter is more desirable.
    $pathInfo = $ExecutionContext.SessionState.Path.CurrentLocation
    $currentPath = if ($pathInfo.Drive) { $pathInfo.Path } else { $pathInfo.ProviderPath }

    # File system paths are case-sensitive on Linux and case-insensitive on Windows and macOS
    if (($PSVersionTable.PSVersion.Major -ge 6) -and $IsLinux) {
        $stringComparison = [System.StringComparison]::Ordinal
    }
    else {
        $stringComparison = [System.StringComparison]::OrdinalIgnoreCase
    }

    # Replace $Home with ~ if possible
    if ($currentPath -and $currentPath.StartsWith($Home, $stringComparison)) {
        $tail = Get-AbbreviatedPath $currentPath.SubString($Home.Length)
        $currentPath = "~" + $tail
    } else {
        $currentPath = Get-AbbreviatedPath $currentPath
    }

    return $currentPath
}

# Jump to directories fast. and
Import-Module ZLocation
New-Alias -Name j -Value z

# Unixification
New-Alias -Name which -Value Get-Command

# Coloured ls
Import-Module Get-ChildItemColor
New-Alias -Name ll -Value Get-ChildItemColor

# Git Functions
function Send-GitPushForce() { git push --force-with-lease }
function Get-GitLog() { git log --pretty=fancy --topo-order }
function Get-GitLogOverview() { git log --pretty=overview --topo-order }
function Get-GitCurrentBranch() {  g rev-parse --abbrev-ref HEAD }

# Git aliases
New-Alias -Name g -Value "git" -Option AllScope
New-Alias -Name gpf -Value "GitPushForce" -Option AllScope
New-Alias -Name gl -Value "Get-GitLog" -Option AllScope -Force
New-Alias -Name glo -Value "Get-GitLogOverview" -Option AllScope

# Add chocolatey tools to this shell if installed
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path $ChocolateyProfile) {
    Import-Module "$ChocolateyProfile"
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
