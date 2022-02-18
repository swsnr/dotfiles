# Copyright Sebastian Wiesner <sebastian@swsnr.de>
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

# Make Windows a bit more bearable
$packages = @(
    "Microsoft.Powertoys",
    "Microsoft.WindowsTerminal",
    "Microsoft.PowerShell"
    "Git.Git",
    "AgileBits.1Password"
)

foreach ($package in $packages) {
    winget install --id $package -e --source winget
}

# TODO: Enable SSH server Windows feature!
# See https://docs.microsoft.com/de-de/windows-server/administration/openssh/openssh_install_firstuse
# Enable and start SSH server
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service sshd

# Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    # New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}
