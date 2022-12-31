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
// Don't nag about default browser
user_pref("browser.shell.checkDefaultBrowser", false);
// Disable firefox view nag screen
user_pref("browser.tabs.firefox-view", false);
// Don't nag about resetting the browser after long inactivity
user_pref("browser.disableResetPrompt", true);
// Restore session on startup
user_pref("browser.startup.page", 3);
// Disable new-tab page
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.newtabpage.enhanced", false);
user_pref("browser.newtabpage.introShown", true);
// Disable sponsored content and other weird stuff
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.section.highlights.includePocket", false);
// Cleary default topsites and pinned sites
user_pref("browser.newtabpage.activity-stream.default.sites", "");
user_pref("browser.newtabpage.pinned", "[{\"url\":\"https://amazon.com\",\"label\":\"@amazon\",\"searchTopSite\":true},{\"url\":\"https://google.com\",\"label\":\"@google\",\"searchTopSite\":true}]");
// Disable recommendations in about:addons
user_pref("extensions.getAddons.showPane", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
// Disable bundled pocket
user_pref("extensions.pocket.enabled", false);
// Disable personalized extension recommendations.
user_pref("browser.discovery.enabled", false);
user_pref("extensions.webservice.discoverURL", "");
// Disable welcome notices
user_pref("browser.startup.homepage_override.mstone", "ignore");

// Linux desktop integration: Enable Gnome search provider and force portal API
// for file dialogs and mime handling.  The latter makes it rely on standard
// desktop services; in particular we get a nice new Gnome file dialog instead
// of the old and ugly Gtk thingy.
user_pref("browser.gnome-search-provider.enabled", true);
user_pref("widget.use-xdg-desktop-portal.mime-handler", 1);
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);

// Content-blocking
user_pref("browser.contentblocking.category", "strict");

// Opt-out from Firefox studies and telemetry
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.healthreport.service.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.server", "");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.coverage.opt-out", true);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.cachedClientID", "");
user_pref("toolkit.telemetry.hybridContent.enabled", false);
user_pref("toolkit.telemetry.prompted", 2);
user_pref("toolkit.telemetry.rejected", true);
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
user_pref("toolkit.telemetry.unifiedIsOptIn", false);
user_pref("toolkit.coverage.opt-out", true); // [FF64+] [HIDDEN PREF]
user_pref("toolkit.coverage.endpoint.base", "");
user_pref("browser.send_pings", false);
user_pref("browser.ping-centre.telemetry", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);
user_pref("browser.crashReports.unsubmittedCheck.enabled", false);
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit", false);
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false);
user_pref("beacon.enabled", false);

// Opt out of all experiments
user_pref("network.allow-experiments", false);
user_pref("experiments.activeExperiment", false);
user_pref("experiments.enabled", false);
user_pref("experiments.manifest.uri", "");
user_pref("experiments.supported", false);

// Disable captive portal detection because it leaks connections to cloudflare
user_pref("network.captive-portal-service.enabled", false);

// Enable built-in tracking protection and privacy features
user_pref("privacy.donottrackheader.enabled", true);
user_pref("privacy.donottrackheader.value", 1);
user_pref("privacy.query_stripping", true);
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
user_pref("privacy.trackingprotection.pbmode.enabled", true);
user_pref("privacy.usercontext.about_newtab_segregation.enabled", true);

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

// Show full URL in URL bar and disable suggestions
user_pref("browser.urlbar.groupLabels.enabled", false);
user_pref("browser.urlbar.quicksuggest.enabled", false);
user_pref("browser.urlbar.trimURLs", false);

// Hardware acceleration for firefox, see https://discourse.flathub.org/t/how-to-enable-video-hardware-acceleration-on-flatpak-firefox/3125
user_pref("gfx.webrender.all", true);
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.ffvpx.enabled", false);
user_pref("media.av1.enabled", false);

// Use mozilla location services
user_pref("geo.provider.network.url", "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%");

// Mark my configuration as loaded
user_pref('_swsnr.user.js', 'Complete');
