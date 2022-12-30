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

// Preferences for firefox.
//
// Much of this is taken from https://github.com/arkenfox/user.js/blob/master/user.js

user_pref('_swsnr.user.js', 'Loading...');

// Do not show warning in about:config
user_pref("browser.aboutConfig.showWarning", false);
// Restore session on startup
user_pref("browser.startup.page", 3);
// Disable new-tab page
user_pref("browser.newtabpage.enabled", false);
// Disable sponsored content and other weird stuff
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
// Cleary default topsites and pinned sites
user_pref("browser.newtabpage.activity-stream.default.sites", "");
user_pref("browser.newtabpage.pinned", "[{\"url\":\"https://amazon.com\",\"label\":\"@amazon\",\"searchTopSite\":true},{\"url\":\"https://google.com\",\"label\":\"@google\",\"searchTopSite\":true}]");
// Enable gnome search provider
user_pref("browser.gnome-search-provider.enabled", true);
// Disable recommendations in about:addons
user_pref("extensions.getAddons.showPane", false); // [HIDDEN PREF]
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
// Disable personalized extension recommendations.
user_pref("browser.discovery.enabled", false);
// Disable welcome notices
user_pref("browser.startup.homepage_override.mstone", "ignore");

// Content-blocking
user_pref("browser.contentblocking.category", "strict");

// Opt-out from Firefox studies and telemetry
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.coverage.opt-out", true);
user_pref("toolkit.coverage.opt-out", true); // [FF64+] [HIDDEN PREF]
user_pref("toolkit.coverage.endpoint.base", "");
user_pref("browser.ping-centre.telemetry", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false);

// Disable search suggestions
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.urlbar.suggest.searches", false);
// Disable speculative connections
user_pref("browser.urlbar.speculativeConnect.enabled", false);
// Do not leak single words to DNS
user_pref("browser.urlbar.dnsResolveSingleWordsAfterSearch", 0);
// Disable auto-fill
user_pref("browser.formfill.enable", false);
user_pref("signon.autofillForms", false);
user_pref("signon.formlessCapture.enabled", false);

// Hardware acceleration for firefox, see https://discourse.flathub.org/t/how-to-enable-video-hardware-acceleration-on-flatpak-firefox/3125
user_pref("gfx.webrender.all", true);
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.ffvpx.enabled", false);
user_pref("media.av1.enabled", false);

// Use mozilla location services
user_pref("geo.provider.network.url", "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%");

// Mark my configuration as loaded
user_pref('_swsnr.user.js', 'Complete');
