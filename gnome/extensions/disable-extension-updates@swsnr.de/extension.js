/* This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published
 * by the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

const ExtensionUtils = imports.misc.extensionUtils;
const downloader = imports.ui.extensionDownloader;

const Me = ExtensionUtils.getCurrentExtension();
const l = message => log(`${Me.metadata.uuid}: ${message}`);

class DisableExtensionUpdates {
  constructor() {
    this._original_checkForUpdates = null;
  }

  enable() {
    if (this._original_checkForUpdates === null) {
      l('enabled: blocking extension updates');
      this._original_checkForUpdates = downloader.checkForUpdates;
      downloader.checkForUpdates = () => {
        l('Extension update check attempted; disabled by disable-extension-updates@swsnr.de');
        return;
      }
    }
  }

  disable() {
    if (this._original_checkForUpdates !== null) {
      l('disabled: extension are checked for updates again');
      downloader.checkForUpdates = this._original_checkForUpdates;
      this._original_checkForUpdates = null;
    }
  }
}

function init() {
  return new DisableExtensionUpdates();
}
