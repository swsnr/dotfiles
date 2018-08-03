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

# Locale for unix programs if not already present
if (-not (Test-Path env:LC_ALL)) {
    $env:LC_ALL = 'en_GB.utf8'
}

# Setup prompt
Import-Module posh-git

# Replace home with ~
$GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true;
# Git prompt settings, see https://github.com/lunaryorn/playbooks/blob/master/roles/fish/files/functions/fish_right_prompt.fish for fish variant
$GitPromptSettings.BranchIdenticalStatusToForegroundColor = 'Green'
# Symbol and colours for working status summary
$GitPromptSettings.LocalStagedStatusSymbol = '●'
$GitPromptSettings.LocalWorkingStatusSymbol = '+'
$GitPromptSettings.LocalWorkingStatusForegroundColor = 'Yellow'
# Color for working status details
$GitPromptSettings.WorkingForegroundColor = 'Magenta'

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

    # If in a Git repository abbreviate the path to show only the root name of
    # the working copy, since my git repos typically have unique names so I'll
    # know where I am at this point.
    $gitDir = Get-GitDirectory
    if ($gitDir -and ((Split-Path $gitDir -Leaf) -eq '.git')) {
        $workingCopyBase = Split-Path $gitDir
        $tail = Get-AbbreviatedPath $currentPath.SubString($workingCopyBase.Length)
        $currentPath = 'git:' + (Split-Path $workingCopyBase -Leaf) + $tail
    }
    # Otherwise just replace $Home with ~ if possible
    elseif ($currentPath -and $currentPath.StartsWith($Home, $stringComparison)) {
        $tail = Get-AbbreviatedPath $currentPath.SubString($Home.Length)
        $currentPath = "~" + $tail
    }

    return $currentPath
}

function prompt {
    $origLastExitCode = $LASTEXITCODE

    $prompt = ''

    if ($origLastExitCode -eq 0) {
        $prompt += Write-Prompt '✔' -ForegroundColor Green
    }
    else {
        $prompt += Write-Prompt '!' -ForegroundColor Red
    }
    $prompt += Write-Prompt ' '
    $prompt += Write-Prompt (Get-PromptWorkingDir) -ForegroundColor Cyan
    $prompt += Write-VcsStatus
    $prompt += Write-Prompt ' '
    $prompt += Write-Prompt "$(if ($PsDebugContext) {' [DBG]: '} else {''})" -ForegroundColor Magenta
    $prompt += Write-Prompt "$('❯' * ($nestedPromptLevel + 1))" -ForegroundColor Green
    $prompt += " "

    $LASTEXITCODE = $origLastExitCode
    $prompt
}

# Jump to directories fast, like autojump
Import-Module Jump.Location

# Line-editing in console hosts
if ($host.Name -eq 'ConsoleHost') {
    Import-Module PSReadLine

    # Disable audible beel
    Set-PSReadlineOption -BellStyle Visual
    # Do not save duplicates in history, move cursor to the end of commands
    # found in history, save history incrementally and vastly increase history.
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
    Set-PSReadLineOption -MaximumHistoryCount 4000

    # Start with Emacs keys, and add custom keybindings
    Set-PSReadlineOption -EditMode Emacs
    # Emulate history-substring search from Fish
    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
    # Default to menu-completion
    Set-PSReadlineKeyHandler -Chord 'Shift+Tab' -Function Complete
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
}

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

# Java options for Java launchers
$env:JAVA_OPTS += ' -Xmx2G -Xss2M'

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
