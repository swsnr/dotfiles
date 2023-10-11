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

import St from 'gi://St';
import GLib from 'gi://GLib';
import Clutter from 'gi://Clutter';

import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js'
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

export default class SpaceTimeFormatsExtension extends Extension {
  constructor(metadata) {
    super(metadata);
    this._clockChangedId = null;
    this._customLabel = null;
  }

  /**
   * A simple accessor to the date menu wall clock.
   */
  get _clock() {
    return Main.panel.statusArea.dateMenu._clock;
  }

  get _originalLabel() {
    return Main.panel.statusArea.dateMenu.label_actor;
  }

  _updateLabel() {
    if (this._customLabel !== null) {
      const theirNow = this._clock.clock;
      const ourNow = GLib.DateTime.new_now_utc().format('%j/%H:%MZ CW %V');
      this._customLabel.set_text(`${theirNow} ${ourNow}`);
    }
  }

  enable() {
    if (this._customLabel === null) {
      console.log(`Extension ${this.uuid} enabled, creating new label`);
      this._customLabel = new St.Label();
      this._customLabel.clutter_text.y_align = Clutter.ActorAlign.CENTER;

      // Hide the original label
      this._originalLabel.set_width(0);
      // Insert our custom label beneath the original label.  We need to use
      // get_parent here because there are intermediate layout actors; the
      // original label is not an immediate child of the date menu.
      this._originalLabel.get_parent().insert_child_below(
        this._customLabel, this._originalLabel)
      this._updateLabel();
    }
    if (this._clockChangedId === null) {
      console.log(`Extension ${this.uuid} enabled, connecting to clock`);
      this._clockChangedId = this._clock.connect('notify::clock', this._updateLabel.bind(this));
    }
  }

  disable() {
    if (this._clockChangedId !== null) {
      console.log(`Extension ${this.uuid} disabled, disconnecting from clock`);
      this._clock.disconnect(this._clockNotifyId);
      this._clockChangedId = null;
    }
    if (this._customLabel !== null) {
      console.log(`Extension ${this.uuid} disabled, destroying custom label`);
      this._customLabel.destroy();
      this._originalLabel.set_width(-1);
      this._customLabel = null;
    }
  }
}
