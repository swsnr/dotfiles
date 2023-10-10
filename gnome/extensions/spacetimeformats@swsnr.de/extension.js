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
import GObject from 'gi://GObject'
import Gio from 'gi://Gio';
import Clutter from 'gi://Clutter';
import GnomeDesktop from 'gi://GnomeDesktop';

import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js'
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';

const SpaceTimesIndicator = GObject.registerClass(
  { GTypeName: "SpaceTimesIndicator" },
  class SpaceTimesIndicator extends PanelMenu.Button {
    _init({ name, settings }) {
      super._init(5, name, true);

      console.info("Listening for setting changes");
      this._settings = settings;
      this._settingsChangedId = this._settings.connect('changed', this._onSettingsChanged.bind(this));

      console.info("Listening for wall clock ticks");
      this._clock = new GnomeDesktop.WallClock()
      this._clockNotifyId = this._clock.connect('notify::clock', this._updateLabel.bind(this));

      this._label = new St.Label();
      this._label.clutter_text.y_align = Clutter.ActorAlign.CENTER;
      this.add_child(this._label);

      this._updateLabel();
      this._onSettingsChanged();
    }

    vfunc_event(event) {
      if (this.menu &&
        (event.type() == Clutter.EventType.TOUCH_BEGIN ||
          event.type() == Clutter.EventType.BUTTON_PRESS)) {
        this._open_uri();
      }

      return Clutter.EVENT_PROPAGATE;
    }

    _open_uri() {
      const uri = this._get_uri_to_open();
      console.info("Trying to open URI after click", uri);
      if (!!uri) {
        Gio.AppInfo.launch_default_for_uri_async(uri, null, null, null);
      }
    }

    _get_uri_to_open() {
      return this._settings.get_string('uri-to-open-on-click');
    }

    _onDestroy() {
      this._label.destroy();
      this._clock.disconnect(this._clockNotifyId);
      this._clock.destroy();
      this._settings.disconnect(this._settingsChangedId);
      this._settings.destroy();
      super._onDestroy();
    }

    _onSettingsChanged() {
      // Enable clicking the indicator only of a URI was configured
      const haveURI = !!this._get_uri_to_open();
      console.info("Updating sensitive state of indicator", haveURI);
      this.setSensitive(haveURI);
    }

    _updateLabel() {
      const now = GLib.DateTime.new_now_utc();
      this._label.set_text(now.format('%j/%H:%MZ CW %V'));
    }
  }
);

export default class SpaceTimeFormatsExtension extends Extension {
  constructor(metadata) {
    super(metadata);
    this.indicator = null;
  }

  enable() {
    if (this.indicator === null) {
      console.log(`Extension ${this.uuid} enabled, creating indicator`);
      const name = `${this.uuid} Indicator`;
      this.indicator = new SpaceTimesIndicator({ name, settings: this.getSettings() });
      Main.panel.addToStatusArea(name, this.indicator);
    }
  }

  disable() {
    if (this.indicator !== null) {
      console.log(`Extension ${this.uuid} disabled, destroying indicator`);
      this.indicator.destroy();
      this.indicator = null;
    }
  }
}
