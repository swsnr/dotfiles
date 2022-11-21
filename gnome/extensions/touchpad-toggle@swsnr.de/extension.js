/* Touchpad Toggle GNOME Shell Extension
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

/**
  * Originally taken from https://github.com/kra-mo/quick-touchpad-toggle
  */

const { Gio, GObject } = imports.gi;

const QuickSettings = imports.ui.quickSettings;
const QuickSettingsMenu = imports.ui.main.panel.statusArea.quickSettings;

const TouchpadToggle = GObject.registerClass(
    class TouchpadToggle extends QuickSettings.QuickToggle {
        _init() {
            super._init({
                label: 'Touchpad',
                toggleMode: true,
            });

            this._settings = new Gio.Settings({ schema_id: 'org.gnome.desktop.peripherals.touchpad' });
            this._settings.bind('disable-while-typing',
                this, 'checked',
                Gio.SettingsBindFlags.INVERT_BOOLEAN);

            this._updateIcon();

            this._settings.connect('changed::disable-while-typing', () => {
                this._updateIcon();
            });
        }

        _isDisabled() {
            return this._settings.get_boolean('disable-while-typing');
        }

        _updateIcon() {
            this.iconName = this._isDisabled() ? 'touchpad-disabled-symbolic' : 'input-touchpad-symbolic';
        }
    });

const TouchpadIndicator = GObject.registerClass(
    class TouchpadIndicator extends QuickSettings.SystemIndicator {
        _init() {
            super._init();

            this._indicator = this._addIndicator();
            this._indicator.iconName = 'input-touchpad-symbolic';
            this._settings = new Gio.Settings({ schema_id: 'org.gnome.desktop.peripherals.touchpad' });
            this._settings.bind('disable-while-typing',
                this._indicator, 'visible',
                Gio.SettingsBindFlags.INVERT_BOOLEAN);
            this.quickSettingsItems.push(new TouchpadToggle());
            this.connect('destroy', () => {
                this.quickSettingsItems.forEach(item => item.destroy());
            });
        }
    });

class Extension {
    constructor() {
        this._indicator = null;
    }

    enable() {
        if (this._indicator === null) {
            this._indicator = new TouchpadIndicator();
            QuickSettingsMenu._indicators.add_child(this._indicator);
            QuickSettingsMenu._addItems(this._indicator.quickSettingsItems);
        }
    }

    disable() {
        if (this._indicator !== null) {
            this._indicator.destroy();
            this._indicator = null;
        }
    }
}

function init(_meta) {
    return new Extension();
}
