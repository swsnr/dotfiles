// Copyright Sebastian Wiesner <sebastian@swsnr.de>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not
// use this file except in compliance with the License. You may obtain a copy of
// the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations under
// the License.

import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js'
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as ExtensionUtils from 'resource:///org/gnome/shell/misc/extensionUtils.js';

export default class DisableExtensionUpdates extends Extension {
  logWithUUID(message) {
    log(`${this.uuid}: ${message}`);
  }

  enable() {
    const l = (message) => this.logWithUUID(message);
    l('Marking all per-user extensions as having an update to suppress update check');
    Main.extensionManager.getUuids().forEach(uuid => {
      const extension = Main.extensionManager.lookup(uuid);
      if (extension.type !== ExtensionUtils.ExtensionType.PER_USER) {
        return;
      }
      l(`Marking per-user extension ${uuid} has having an update`);
      extension.hasUpdate = true;
    });
  }

  disable() { }
}
