#!/usr/bin/env bash
# Copyright Sebastian Wiesner <sebastian@swsnr.de>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

acme_config="${XDG_CONFIG_HOME:=${HOME}/.config}/acme.sh"
acme_data="${XDG_DATA_HOME:=${HOME}/.local/share}/acme.sh"

acme.sh \
    --home "${acme_data}" --config-home "${acme_config}" --cert-home "${acme_data}/certs" \
    -d 'kastl.dahoam.swsnr.de' -d '*.kastl.dahoam.swsnr.de' \
    --renew --dns --yes-I-know-dns-manual-mode-enough-go-ahead-please
