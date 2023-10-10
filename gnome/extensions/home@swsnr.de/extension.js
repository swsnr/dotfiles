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

import St from "gi://St";
import GLib from "gi://GLib";
import GObject from "gi://GObject";
import Gio from "gi://Gio";
import Clutter from "gi://Clutter";

import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js'
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import { PopupMenuItem } from 'resource:///org/gnome/shell/ui/popupMenu.js';

// Shouldn't this be upstreamed to Gjs?
Gio._promisify(Gio.Subprocess.prototype, 'communicate_utf8_async');

const getRoutes = async () => {
  const flags = Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE
  const proc = Gio.Subprocess.new(["home"], flags);
  const [stdout, stderr] = await proc.communicate_utf8_async(null, null);
  if (proc.get_successful()) {
    return stdout.trim().split("\n");
  } else {
    throw new Error(`home failed: ${stderr}`);
  }
}

const updateRoutesOnIndicator = async (indicator) => {
  try {
    indicator.showRoutes(await getRoutes());
  } catch (error) {
    console.error("Failed to update routes", error);
    indicator.showError(error);
  }
};

const HomeIndicator = GObject.registerClass(
  { GTypeName: "HomeIndicator" },
  class HomeIndicator extends PanelMenu.Button {
    _init({ name }) {
      super._init(0, name, false);

      this.routes = null;

      this._label = new St.Label({ text: "🚆 n.a." });
      this._label.clutter_text.y_align = Clutter.ActorAlign.CENTER;
      this.add_child(this._label);
    }

    _onDestroy() {
      this._routes = null;
      this.remove_child(this._label);
      this._label.destroy();
      super._onDestroy();
    }

    showRoutes(routes) {
      this.menu.removeAll();
      if (routes) {
        this._label.set_text(routes[0]);
        routes.slice(1).forEach(route => {
          this.menu.addMenuItem(new PopupMenuItem(route));
        });
      } else {
        this._label.set_text("🚆 n.a.");
        this.menu.addMenuItem(new PopupMenuItem("no more routes"));
      }
    }

    showError(error) {
      this._label.set_text(`Error: ${error}`);
      this.menu.removeAll();
    }
  }
);

export default class HomeExtension extends Extension {
  constructor(metadata) {
    super(metadata);

    this.indicator = null;
    this.sourceIdOfRefreshTimer = null;
    this.shallRefreshAgain = true;
  }

  enable() {
    if (this.indicator === null) {
      console.log(`Extension ${this.uuid} enabled, creating indicator`);
      const name = `${this.uuid} Indicator`;
      this.indicator = new HomeIndicator({ name });
      Main.panel.addToStatusArea(name, this.indicator);

      console.log("Getting initial routes");
      updateRoutesOnIndicator(this.indicator);

      console.log("Starting to refresh routes once per minute");
      this.shallRefreshAgain = true;
      this.sourceIdOfRefreshTimer = GLib.timeout_add_seconds(
        GLib.PRIORITY_DEFAULT,
        60,
        () => {
          updateRoutesOnIndicator(this.indicator);
          return this.shallRefreshAgain;
        }
      );
    }
  }

  disable() {
    if (this.indicator !== null) {
      console.log(`Extension ${this.uuid} disabled, stopping refresh timer`);
      this.shallRefreshAgain = false;
      GLib.source_remove(this.sourceIdOfRefreshTimer);
      console.log("Destroying indicator");
      this.indicator.destroy();
      this.indicator = null;
    }
  }
}
