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

import sys
import os
import re
import argparse
from argparse import ArgumentParser, ArgumentError
from collections.abc import Collection
from pathlib import Path
from socket import gethostname
from subprocess import run
from tempfile import NamedTemporaryFile


XDG_CACHE_DIR = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache"))
GPGKEY = "B8ADA38BC94C48C4E7AABE4F7548C2CC396B57FC"
MAKEPKG_CONF = "/usr/share/devtools/makepkg.conf.d/x86_64.conf"
PACKAGER = "Sebastian Wiesner <sebastian@swsnr.de>"


os.environ["PACKAGER"] = PACKAGER
os.environ["GPGKEY"] = GPGKEY
os.environ["AUR_PAGER"] = "nnn -e"

BACKUP_REPO = f"rclone:kastl:restic-{os.getlogin()}"
BACKUP_TAG = "kastl-swsnr-repo"


class Repo:
    """A package repository."""

    def __init__(self: "Repo", dbpath: Path) -> None:
        """Initialize a package repository with the given database."""
        self.db = dbpath.absolute()
        self.directory = self.db.parent
        self.name = self.db.name.removesuffix(".db.tar.zst")

    def packages(self: "Repo", *, with_versions: bool=False) -> list[str]:
        """Get a list of all packages in the given repository."""
        cmd = ["/usr/bin/aur", "repo", "-d", self.name, "-l"]
        if not with_versions:
            cmd.append("-q")
        return run(cmd, check=True, capture_output=True, text=True).stdout.splitlines()


#: AUR packages to build
AUR_PACKAGES: list[str] = [
    "1password",
    "1password-cli",
    "aurutils",
    "gnome-search-providers-vscode",
    "gnome-shell-extension-disable-extension-updates",
    "gnome-shell-extension-picture-of-the-day",
    "gnome-shell-extension-utc-clock",
    "otf-vollkorn",
    "pcsc-cyberjack",
]

#: Packages to remove from the repository
PACKAGES_TO_REMOVE: list[str] = [
    # Not used anymore
    "frum",
    # Moved to extra
    "gnome-shell-extension-caffeine",
    # Not ported to GNOME 45 yet, superseded by picture-of-the-day
    "gnome-shell-extension-nasa-apod",
    # Not used anymore
    "python2",
    "rocketchat-desktop",
    "sol2",
    "sol2-single",
    "string-theory",
    "archlinux-java-run",
    "pacman-hook-reproducible-status",
    "pacman-hook-kernel-install",
    "wcal-git",
    # Use flatpak instead
    "ausweisapp2",
    "chiaki",
    "televido",
    "threema-desktop",
    "whatsapp-for-linux",
    "jabref",
    "sioyek",
    "ja2-stracciatella",
    "ja2-stracciatella-git",
    # Moved to my OBS repo
    "git-gone",
]

class regex_in(str): # noqa: N801,SLOT000
    """Match a regex in a string in structural pattern matching."""

    def __eq__(self: str, pattern: object) -> bool:
        """Check whether this string matches `pattern`."""
        return isinstance(pattern, str) and bool(re.search(pattern, self))


#: Packages we only build on some hosts
match regex_in(gethostname()):
    case "kastl":
        AUR_PACKAGES.extend([
            "gnome-shell-extension-gsconnect",
            "ruby-install",
        ])
    case "RB":
        AUR_PACKAGES.extend([
            "gnome-search-providers-jetbrains",
            "age-plugin-tpm",
            "fnm",
        ])


def get_outdated_vcs_packages(repo: Repo, packages: list[str]) -> list[str]:
    """Get all outdated VCS packages from `packages`."""
    if not packages:
        return []

    pkgnames_with_versions = repo.packages(with_versions=True)

    with NamedTemporaryFile() as vcs_versions_file:
        aurutils_sync_dir = XDG_CACHE_DIR / "aurutils" / "sync"
        run(["/usr/bin/aur", "srcver", "--noprepare", *packages],
            cwd=aurutils_sync_dir, check=True, stdout=vcs_versions_file)
        return run(["/usr/bin/aur", "vercmp", "-q", "-p", vcs_versions_file.name],
            check=True, text=True, capture_output=True,
            input="\n".join(pkgnames_with_versions)).stdout.splitlines()


def remove_packages(repo: Repo, packages: Collection[str]) -> None:
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


def get_packages_to_remove(repo: Repo) -> Collection[str]:
    """Get all packages to remove from the repo.

    Includes packages explicitly designated for removal, as well as redundant
    debug packages.
    """
    repo_packages = set(repo.packages(with_versions=False))
    orphan_debug_pkgnames = {p for p in repo_packages
                             if p.endswith("-debug") and
                             p.removesuffix("-debug") not in repo_packages}

    pkgnames = set(PACKAGES_TO_REMOVE) | \
        {f"{p}-debug" for p in PACKAGES_TO_REMOVE} | \
        orphan_debug_pkgnames
    return repo_packages & pkgnames


def cleanup_repo(repo: Repo) -> None:
    """Cleanup the repo.

    Delete packages to be removed, and remove debug packages where the original
    package was removed.
    """
    remove_packages(repo, get_packages_to_remove(repo))


def backup(repo: Repo) -> None:
    """Backup the entire repo."""
    run(["/usr/bin/restic", "-r", BACKUP_REPO, "backup", str(repo.directory),
         "--tag", BACKUP_TAG, "--exclude-caches"], check=True)
    run(["/usr/bin/restic", "-r", BACKUP_REPO, "forget", "--keep-last", "3",
         "--path", str(repo.directory), "--tag", BACKUP_TAG, "--prune"], check=True)


def _action_create_repo(repo: Repo, _args: argparse.Namespace) -> None:
    """Create the initial empty repository."""
    if repo.db.exists():
        msg = f"Repository already exists at {repo.db}"
        raise ValueError(msg)

    # Create the top-level repository directory
    run(["/usr/bin/sudo", "install", "-m755", "-d", str(repo.directory.parent)],
        check=True)
    # Create a btrfs subvolume for the repository directory itself
    run(["/usr/bin/sudo", "btrfs", "subvolume", "create", str(repo.directory)],
        check=True)
    # Make myself owner of the repo directory
    uid = os.getuid()
    gid = os.getgid()
    run(["/usr/bin/sudo", "chown", "-R", f"{uid}:{gid}", str(repo.directory)],
        check=True)
    # Create an empty database
    run(["/usr/bin/repo-add", "--sign", "--key", GPGKEY, str(repo.db)], check=True)


def _action_restore(repo: Repo, args: argparse.Namespace) -> None:
    """Restore the contents of the repository."""
    restore = ["/usr/bin/restic", "-r", BACKUP_REPO, "restore",
               "-t", BACKUP_TAG, "--path", str(repo.directory),
               "--target", "/", "latest"]
    if args.verbose:
        restore.append("--verbose")
    run(restore, check=True)


def _action_aur_sync(repo: Repo, _args: argparse.Namespace) -> None:
    """Sync all desired AUR packages."""
    cleanup_repo(repo)
    sync_cmd = [
        "/usr/bin/aur", "sync", "-d", repo.name,
        "--nocheck", "-ucRS",
        "--makepkg-conf", MAKEPKG_CONF,
    ]

    run([*sync_cmd, *AUR_PACKAGES], check=True)

    vcs_packages = [pkg for pkg in AUR_PACKAGES if pkg.endswith("-git")]
    outdated_vcs_packages = get_outdated_vcs_packages(repo, vcs_packages)
    if outdated_vcs_packages:
        run([*sync_cmd, *outdated_vcs_packages], check=True)


def _action_build_pkgbuild(repo: Repo, args: argparse.Namespace) -> None:
    """Build a directory with a PKGBUILD and add the result to the repo."""
    pkgbuild = args.directory / "PKGBUILD"
    if not pkgbuild.exists():
        msg = f"Missing PKGBUILD in {args.directory}"
        raise ValueError(msg)
    build_cmd = [
        "/usr/bin/aur", "build", "-d", repo.name,
        "-cRS", "--nocheck", "--makepkg-conf", MAKEPKG_CONF,
    ]
    run(build_cmd, check=True, cwd=args.directory)


def _action_backup(repo: Repo, _args: argparse.Namespace) -> None:
    """Backup the repo."""
    backup(repo)


def _action_update_repo(repo: Repo, _args: argparse.Namespace) -> None:
    """Update the repo.

    Add all package files in the repo dir to the database, then completely
    remove all packages desired to be removed.
    """
    repo_add = ["/usr/bin/repo-add", "--sign", "--key", GPGKEY, repo.db]
    repo_add.extend(repo.directory.glob("*.pkg.tar.zst"))
    run(repo_add, check=True)

    cleanup_repo(repo)


def _action_cleanup(repo: Repo, _args: argparse.Namespace) -> None:
    """Cleanup the repo."""
    cleanup_repo(repo)


def _action_remove_packages(repo: Repo, args: argparse.Namespace) -> None:
    """Remove packages specified given on command line."""
    remove_packages(repo, args.packages)


def main() -> None:
    """Run this program."""
    parser = ArgumentParser(
        description="Manage my custom repo of AUR and other packages.",
        exit_on_error=False,
    )
    subparsers = parser.add_subparsers(required=True)

    actions = [
        "create-repo",
        "aur-sync",
        "backup",
        "restore",
        "update-repo",
        "cleanup",
        "build-pkgbuild",
        "remove-packages",
    ]
    parsers: dict[str, ArgumentParser] = {}
    for action in actions:
        parsers[action] = subparsers.add_parser(action)
        name = action.replace("-", "_")
        parsers[action].set_defaults(action_callback=globals()[f"_action_{name}"])

    parsers["remove-packages"].add_argument("packages", nargs="+")
    parsers["build-pkgbuild"].add_argument("directory", type=Path)
    parsers["restore"].add_argument("--verbose", action="store_true")

    try:
        args = parser.parse_args()
    except ArgumentError as error:
        print(error, file=sys.stderr)  # noqa: T201
        print(parser.format_help(), file=sys.stderr)  # noqa: T201
        sys.exit(1)

    repo = Repo(Path("/srv/pkgrepo/swsnr/swsnr.db.tar.zst"))
    args.action_callback(repo, args)


if __name__ == "__main__":
    main()
