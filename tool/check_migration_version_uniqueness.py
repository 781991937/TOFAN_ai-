#!/usr/bin/env python3
"""Fail when SQL migration filenames are malformed or reuse a version prefix.

This checks repository naming integrity only. It does not compare local files with
Supabase's remote migration ledger and must never be treated as migration approval.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Iterable

MIGRATION_NAME = re.compile(r"^(?P<version>[0-9]+)_[a-z0-9][a-z0-9_-]*\.sql$", re.IGNORECASE)


def migration_name_issues(paths: Iterable[Path]) -> list[str]:
    """Return deterministic naming/collision errors for the supplied SQL paths."""
    issues: list[str] = []
    seen: dict[int, Path] = {}

    for path in sorted(paths, key=lambda item: item.name):
        match = MIGRATION_NAME.fullmatch(path.name)
        if match is None:
            issues.append(
                f"{path.name}: expected '<numeric-version>_<descriptive_name>.sql'"
            )
            continue

        version = int(match.group("version"))
        previous = seen.get(version)
        if previous is not None:
            issues.append(
                f"duplicate migration version {version}: {previous.name} and {path.name}"
            )
        else:
            seen[version] = path

    return issues


def main() -> int:
    migration_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("supabase/migrations")
    if not migration_dir.is_dir():
        print(f"ERROR: migration directory not found: {migration_dir}", file=sys.stderr)
        return 2

    paths = list(migration_dir.glob("*.sql"))
    if not paths:
        print(f"ERROR: no SQL migrations found in {migration_dir}", file=sys.stderr)
        return 2

    issues = migration_name_issues(paths)
    if issues:
        print("Migration filename validation failed:")
        for issue in issues:
            print(f"- {issue}")
        return 1

    print(f"PASS: {len(paths)} SQL migration filenames have unique numeric versions.")
    print("NOTE: remote Supabase migration history/content reconciliation is a separate gate.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
