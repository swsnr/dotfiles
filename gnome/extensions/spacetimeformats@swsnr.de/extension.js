/* extension.js
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/* exported init */

const { St, GLib, GObject, Gio, Clutter, GnomeDesktop } = imports.gi;

const Main = imports.ui.main;
const ExtensionUtils = imports.misc.extensionUtils;
const PanelMenu = imports.ui.panelMenu;
const Util = imports.misc.util;

const Me = ExtensionUtils.getCurrentExtension();

const l = message => log(`${Me.metadata.uuid}: ${message}`);

const SpaceTimesIndicator = GObject.registerClass(
  { GTypeName: "SpaceTimesIndicator" },
  class SpaceTimesIndicator extends PanelMenu.Button {
    _init() {
      super._init(0.0, `${Me.metadata.name} Indicator`, true);
      this._settings = ExtensionUtils.getSettings();
      this._settingsChangedId = this._settings.connect('changed', this._onSettingsChanged.bind(this));

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
      this.setSensitive(!!this._get_uri_to_open());
    }

    _updateLabel() {
      const now = GLib.DateTime.new_now_utc();
      this._label.set_text(now.format('%j/%H:%MZ CW %V'));
    }
  }
);

class Extension {
  constructor() {
    this.indicator = null;
  }

  enable() {
    l("enabled");
    if (this.indicator === null) {
      this.indicator = new SpaceTimesIndicator();
      Main.panel.addToStatusArea(
        `${Me.metadata.name} Indicator`,
        this.indicator,
      );
    }
  }

  disable() {
    l("disabled");
    if (this.indicator !== null) {
      this.indicator.destroy();
      this.indicator = null;
    }
  }
}

function init() {
  return new Extension();
}
