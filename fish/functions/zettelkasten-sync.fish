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

function zettelkasten-sync -d "Synchronize Zettelkasten"
    op-signin
    set -l directory
    if set -q ZETTELKASTEN_DIRECTORY
        set directory $ZETTELKASTEN_DIRECTORY
    else
        set directory (xdg-user-dir DOCUMENTS)/Zettelkasten
    end

    # Check that directory is valid
    if ! test -f $directory/notebook.zim
        echo "$directory does not look like a Zim notebook"
        return 1
    end

    set -l match (string match --regex 'name\s*=\s*(.*)' < $directory/notebook.zim)
    # Fish array indexes are 1-based, so the first group is in index 2
    set -l name $match[2]
    if test "$name" != Zettelkasten
        echo "Notebook in $directory has name $name, but expected Zettelkasten"
        return 1
    else
        # TODO: Use bidirectional sync once it becomes stable
        # See https://github.com/rclone/rclone/issues/118
        rclone sync --verbose $directory zettelkasten-mailbox:
    end
end
