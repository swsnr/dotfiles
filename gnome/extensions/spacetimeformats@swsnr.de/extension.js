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
const Me = imports.misc.extensionUtils.getCurrentExtension();
const PanelMenu = imports.ui.panelMenu;
const Util = imports.misc.util;

const l = message => log(`${Me.metadata.uuid}: ${message}`);

const SpaceTimesIndicator = GObject.registerClass(
  { GTypeName: "SpaceTimesIndicator" },
  class SpaceTimesIndicator extends PanelMenu.Button {
    _init() {
      super._init(0.0, `${Me.metadata.name} Indicator`, false);
      // There's no point pressing this
      this.setSensitive(false);

      this._clock = new GnomeDesktop.WallClock()
      this._clockNotifyId = this._clock.connect('notify::clock', this._updateLabel.bind(this));

      this._label = new St.Label();
      this._label.clutter_text.y_align = Clutter.ActorAlign.CENTER;
      this.add_child(this._label);

      this._updateLabel();
    }

    _onDestroy() {
      this._label.destroy();
      this._clock.disconnect(this._clockNotifyId);
      this._clock.destroy();
    }

    _updateLabel() {
      const now = GLib.DateTime.new_now_utc();
      this._label.set_text(now.format('DOY %j  CW %V  %H:%MZ'));
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
        1,
        'center'
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
