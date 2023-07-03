#!/usr/bin/env python3
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

"""Build AUR packages I use."""


import os
import re
from pathlib import Path
from socket import gethostname
from subprocess import DEVNULL, run
from tempfile import NamedTemporaryFile


XDG_CACHE_DIR = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache"))
GPGKEY = "B8ADA38BC94C48C4E7AABE4F7548C2CC396B57FC"
MAKEPKG_CONF = "/usr/share/devtools/makepkg.conf.d/x86_64.conf"
PACKAGER = "Sebastian Wiesner <sebastian@swsnr.de>"


os.environ["PACKAGER"] = PACKAGER


class Repo:
    """A package repository."""

    def __init__(self: "Repo", dbpath: Path) -> None:
        """Initialize a package repository with the given database."""
        self.db = dbpath.absolute()
        self.directory = self.db.parent
        self.name = self.db.name.removesuffix(".db.tar.zst")


PACKAGES = [
    "1password",
    "1password-cli",
    "aurutils",
    "cargo-vet",
    "firefox-gnome-search-provider",
    "fnm",
    "frum",
    "git-gone",
    "gnome-search-providers-jetbrains",
    "gnome-shell-extension-nasa-apod",
    "jabref",
    "otf-vollkorn",
    "pacman-hook-kernel-install",
    "pacman-hook-reproducible-status",
    "pcsc-cyberjack",
]

class regex_in(str): # noqa: N801,SLOT000
    """Match a regex in a string in structural pattern matching."""

    def __eq__(self: str, pattern: str) -> bool:
        """Check whether this string matches `pattern`."""
        return bool(re.search(pattern, self))


match regex_in(gethostname()):
    case "kastl":
        PACKAGES.extend([
            "ausweisapp2",
            "chiaki-git",
            "gnome-shell-extension-gsconnect",
            "ja2-stracciatella",
            "threema-desktop",
            "whatsapp-for-linux",
        ])
    case "RB":
        PACKAGES.extend([
            "drawio-desktop",
            "python2",
            "rocketchat-desktop",
        ])


def bootstrap() -> None:
    """Bootstrap aurutils and the aur repo."""
    # TODO: Attempt to restore from backup automatically
    # TODO: Run the equivalent of this code for bootstrapping aurutils:
    # trap "rm -rf '$BDIR'" EXIT
    # echo "Building aurutils in $BDIR"
    # cd "$BDIR"
    # git clone --depth=1 "https://aur.archlinux.org/aurutils.git"
    # cd aurutils
    # makepkg --noconfirm --nocheck -rsi --sign
    # TODO: Run the equivalent of this code to create the repository subvolumne
    # set -xeuo pipefail
    # install -m755 -d /srv/pkgrepo
    # btrfs subvolumne create "/srv/pkgrepo/aur"
    # chown -R "${SUDO_UID}:$(id -g "$SUDO_UID")" "/srv/pkgrepo/aur"
    # TODO: Create initial database with this:
    # repo-add --sign --key "$GPGKEY" "$REPODB"
    raise NotImplementedError


def collect_dependencies(packages: list[str]) -> list[str]:
    """Collect `packages` and all AUR dependencies."""
    depend_order = run(["/usr/bin/aur", "depends", "--reverse", *packages], text=True,
                       capture_output=True, check=True).stdout
    # We could perhaps do this in python, but shelling out to tsort is just a
    # bit more convenient
    return run(
        ["/usr/bin/tsort"], input=depend_order,
        capture_output=True, text=True, check=True).stdout.splitlines()


def add_debug_packages(packages: list[str]) -> list[str]:
    """Return `packages` and all potential debug packages."""
    return packages + [f"{pkg}-debug" for pkg in packages]


def get_packages_in_repo(repo: Repo, *, with_versions: bool) -> list[str]:
    """Get a list of all packages in the given repository."""
    cmd = ["/usr/bin/aur", "repo", "-d", repo.name, "-l"]
    if not with_versions:
        cmd.append("-q")
    return run(cmd, check=True, capture_output=True, text=True).stdout.splitlines()


def get_outdated_vcs_packages(repo: Repo, packages: list[str]) -> list[str]:
    """Get all outdated VCS packages from `packages`."""
    if not packages:
        return []

    repo_packages_with_version = get_packages_in_repo(repo, with_versions=True)

    with NamedTemporaryFile() as vcs_versions_file:
        aurutils_sync_dir = XDG_CACHE_DIR / "aurutils" / "sync"
        run(["/usr/bin/aur", "srcver", "--noprepare", *packages],
            cwd=aurutils_sync_dir, check=True, stdout=vcs_versions_file)
        return run(["/usr/bin/aur", "vercmp", "-q", "-p", vcs_versions_file.name],
            check=True, text=True, capture_output=True,
            input="\n".join(repo_packages_with_version)).stdout.splitlines()


def remove_packages(repo: Repo, packages: set[str]) -> None:
    """Remove the given list of packages from `repo`.

    Delete package files as well as database entries.
    """
    if not packages:
        return

    for entry in repo.directory.iterdir():
        if entry.is_file() and entry.name.endswith(".pkg.tar.zst"):
            [pkgname, _, _, _] = entry.name.rsplit("-", 3)
            if pkgname in packages:
                entry.unlink()
                sigfile = entry.with_suffix(".zst.sig")
                if sigfile.is_file():
                    sigfile.unlink()

    run(["/usr/bin/repo-remove", "--sign", "--key", GPGKEY, repo.db, *packages],
        check=True)


def backup(repo: Repo) -> None:
    """Backup the entire repo."""
    username = os.getlogin()
    backup_repo = f"rclone:kastl:restic-{username}"
    tag = "kastl-aur-repo"
    run(["/usr/bin/restic", "-r", backup_repo, "backup", str(repo.directory),
         "--tag", tag, "--exclude-caches"], check=True)
    run(["/usr/bin/restic", "-r", backup_repo, "forget", "--keep-last", "3",
         "--path", str(repo.directory), "--tag", tag, "--prune"], check=True)


def main() -> None:
    """Run this program."""
    repo = Repo(Path("/srv/pkgrepo/aur/aur.db.tar.zst"))
    # TODO: bootstrap()
    packages_with_dependencies = collect_dependencies(PACKAGES)
    all_packages = set(add_debug_packages(packages_with_dependencies))
    packages_in_repo = set(get_packages_in_repo(repo, with_versions=False))

    remove_packages(repo, packages_in_repo - all_packages)

    sync_cmd = [
        "/usr/bin/aur", "sync", "-d", repo.name,
        "--nocheck", "-ucRS",
        "--makepkg-conf", MAKEPKG_CONF,
    ]

    run([*sync_cmd, *PACKAGES], check=True)

    vcs_packages = [pkg for pkg in packages_with_dependencies if pkg.endswith("-git")]
    outdated_vcs_packages = get_outdated_vcs_packages(repo, vcs_packages)
    if outdated_vcs_packages:
        run([*sync_cmd, *outdated_vcs_packages], check=True)

    query = run(["/usr/bin/resolvectl", "query", "kastl.local"],
                stdout=DEVNULL, stderr=DEVNULL)
    if "kastl" in gethostname() and query.returncode == 0:
        backup(repo)


if __name__ == "__main__":
    main()
