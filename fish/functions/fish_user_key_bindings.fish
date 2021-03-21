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
# License for the spec

function fish_user_key_bindings
    fish_default_key_bindings

    if test "$fish_key_bindings" = fish_vi_key_bindings
        or test "$fish_key_bindings" = fish_hybrid_key_bindings

        # Get back to normal mode with jk
        bind -M insert -m default jk force-repaint

        # Prepend sudo to the command line with leader s
        bind -M default ' s' __fish_prepend_sudo

        # Execute current autosuggestion with space space
        bind -M default '  ' accept-autosuggestion execute
    else
        bind \e\[3\;5~ kill-word
        bind \cH backward-kill-word
        bind \cV beginning-of-line
        bind \f end-of-line
    end
end
