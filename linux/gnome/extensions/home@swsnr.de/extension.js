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

const GObject = imports.gi.GObject;
const Gio = imports.gi.Gio;
const St = imports.gi.St;

const Main = imports.ui.main;
const Self = imports.misc.extensionUtils.getCurrentExtension();
const Main = imports.ui.Main;
const PanelMenu = imports.ui.panelMenu;

const l = (message) => log(`${Self.metadata.name}: ${message}`);

const HomeIndicator = GObject.registerClass(
    { GTypeName: 'HomeIndicator' },
    class HomeIndicator extends PanelMenu.Button {
        _init() {
            super._init(0.0, `${Me.metadata.name} Indicator`, false);

            this.label = new St.Label({ text: 'Hello World' });
            this.actor.add_child(this.label);

            this.menu.addAction('Menu Item', this.listFutureRoutes, null);
        }

        listFutureRoutes() {
            l('Listing future routes');
        }
    }
);



class Extension {
    constructor() {
        this.indicator = null;
    }

    enable() {
        l('enabled');
        if (this.indicator === null) {
            this.indicator = new HomeIndicator();
            Main.panel.addToStatusArea(`${Me.metadata.name} Indicator`, this.indicator);
        }
    }

    disable() {
        l('disabled');
        if (this.indicator !== null) {
            this.indicator.destroy();
            this.indicator = null;
        }
    }
}

function init() {
    return new Extension();
}
