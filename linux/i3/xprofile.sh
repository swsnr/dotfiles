# Copyright 2018-2019 Sebastian Wiesner <sebastian@swsnr.de>
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

# POSIX shell profile for global environment, because not all environment source
# fish's settings.

# Import paths from fish
export "$(fish -l -c env | grep -e '^PATH=')"
export "$(fish -l -c env | grep -e '^MANPATH=')"
export "$(fish -l -c env | grep -e '^INFOPATH=')"

# Make Qt5 apps use qt5ct
export QT_QPA_PLATFORMTHEME=qt5ct

# Restore screen layout (GDM runs on wayland and doesn't help us here)
autorandr --change --default clone-largest
