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

# Line editing and history for console hosts
Import-Module PSReadLine

# Disable audible bell
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

# Custom colours for readline highlighting
Set-PSReadlineOption -Colors @{
    Emphasis  = [ConsoleColor]::White
    Error     = [ConsoleColor]::Red
    Comment   = [ConsoleColor]::Green
    Keyword   = [ConsoleColor]::White
    String    = [ConsoleColor]::Yellow
    Operator  = [ConsoleColor]::Magenta
    Variable  = [ConsoleColor]::Yellow
    Parameter = [ConsoleColor]::Cyan
    Number    = [ConsoleColor]::Blue
}
