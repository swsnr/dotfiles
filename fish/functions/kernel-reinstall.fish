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

function kernel-reinstall -d 'Reinstall kernels'
    if not argparse v/verbose a/all h/help -- $argv
        return 1
    end
    if set -q _flag_h
        echo 'kernel-reinstall [--all] [--verbose]'
        echo ''
        echo 'Reinstall kernels to /efi'
        echo
        echo '-a --all'
        echo '   Reinstall all kernels (default current kernel)'
        echo '-v --verbose'
        echo '   Run kernel-install verbosely'
        return
    end

    set -l kernel_versions
    set -l kernel_install_options
    if set -q _flag_a
        for entry in /usr/lib/modules/*
            if test -d $entry
                set -a kernel_versions (path basename $entry)
            end
        end
    else
        set -a kernel_versions (uname -r)
    end

    if set -q _flag_v
        set -a kernel_install_options --verbose
    end

    for kernel_version in $kernel_versions
        set -l kernel_image /usr/lib/modules/$kernel_version/vmlinuz
        if test -f $kernel_image
            echo "Reinstalling kernel $kernel_version from $kernel_image"
            sudo kernel-install $kernel_install_options remove $kernel_version
            sudo kernel-install $kernel_install_options add $kernel_version $kernel_image
        else
            echo "Skipping $kernel_version, kernel image not found at $kernel_image"
        end
    end
end
