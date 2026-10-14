#!/usr/bin/env python3
"""Validate the executable baseline registry against ROADMAP.md.

This gate deliberately treats the roadmap's reference status as a claim to
verify, not as proof. A registry entry can only be promoted from
NEEDS_VERIFICATION after code, test, and execution evidence are recorded.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

ITEM_PATTERN = re.compile(
    r"\|\s*(\d{2,3})\s*\|\s*([^|\n]+?)\s*\|\s*([^|\n]+?)\s*\|\s*([^|\n]+?)\s*\|\s*([^|\n]+?)\s*\|"
)
VALID_VERIFICATION = {"NEEDS_VERIFICATION", "PARTIALLY_VERIFIED", "VERIFIED", "BLOCKED"}


def parse_roadmap(path: Path) -> dict[str, dict[str, str]]:
    text = path.read_text(encoding="utf-8")
    items: dict[str, dict[str, str]] = {}
    for match in ITEM_PATTERN.finditer(text):
        item_id, name, phase, status, dependency = match.groups()
        if item_id in items:
            raise ValueError(f"duplicate roadmap item #{item_id}")
        items[item_id] = {
            "name": name.strip(),
            "phase": phase.strip(),
            "reference_status": status.strip(),
            "dependencies": dependency.strip(),
        }
    if len(items) != 120 or set(items) != {f"{index:02d}" for index in range(1, 121)}:
        found = ", ".join(sorted(items))
        raise ValueError(f"expected exactly items 01-120, found {len(items)}: {found}")
    return items


def load_registry(path: Path) -> dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict) or not isinstance(payload.get("items"), list):
        raise ValueError("registry must be an object containing an items array")
    return payload


def check_path(root: Path, value: str, field: str, item_id: str, errors: list[str]) -> None:
    candidate = (root / value).resolve()
    if not candidate.is_relative_to(root.resolve()):
        errors.append(f"#{item_id} {field} escapes repository: {value}")
    elif not candidate.exists():
        errors.append(f"#{item_id} {field} does not exist: {value}")


def validate(root: Path, roadmap: Path, registry_path: Path) -> tuple[list[str], dict[str, int]]:
    errors: list[str] = []
    roadmap_items = parse_roadmap(roadmap)
    registry = load_registry(registry_path)
    if registry.get("schema_version") != 1:
        errors.append("registry schema_version must be 1")
    if registry.get("roadmap") != "docs/ROADMAP.md":
        errors.append("registry roadmap must be docs/ROADMAP.md")
    if registry.get("repository") != "781991937/TOFAN_ai-":
        errors.append("registry repository must be 781991937/TOFAN_ai-")

    entries = registry["items"]
    by_id: dict[str, dict[str, Any]] = {}
    for entry in entries:
        if not isinstance(entry, dict):
            errors.append("every registry item must be an object")
            continue
        item_id = str(entry.get("id", ""))
        if item_id in by_id:
            errors.append(f"duplicate registry item #{item_id}")
        by_id[item_id] = entry
        required = {
            "id",
            "name",
            "phase",
            "reference_status",
            "dependencies",
            "verification",
            "code_paths",
            "test_paths",
            "evidence",
            "notes",
        }
        missing = sorted(required - set(entry))
        if missing:
            errors.append(f"#{item_id} missing fields: {', '.join(missing)}")
            continue
        if entry["verification"] not in VALID_VERIFICATION:
            errors.append(f"#{item_id} has invalid verification state: {entry['verification']}")
        if not isinstance(entry["code_paths"], list) or not isinstance(entry["test_paths"], list):
            errors.append(f"#{item_id} code_paths and test_paths must be arrays")
        if not isinstance(entry["evidence"], list) or not entry["evidence"]:
            errors.append(f"#{item_id} must have at least one evidence record")
        for field in ("code_paths", "test_paths"):
            for value in entry[field] if isinstance(entry[field], list) else []:
                if not isinstance(value, str):
                    errors.append(f"#{item_id} {field} contains a non-string path")
                else:
                    check_path(root, value, field, item_id, errors)
        if entry["verification"] == "VERIFIED" and (not entry["code_paths"] or not entry["test_paths"]):
            errors.append(f"#{item_id} cannot be VERIFIED without code and test paths")

    expected_ids = set(roadmap_items)
    actual_ids = set(by_id)
    for item_id in sorted(expected_ids - actual_ids):
        errors.append(f"missing registry entry for roadmap item #{item_id}")
    for item_id in sorted(actual_ids - expected_ids):
        errors.append(f"registry item #{item_id} is not present in ROADMAP.md")
    for item_id in sorted(expected_ids & actual_ids):
        expected = roadmap_items[item_id]
        actual = by_id[item_id]
        for field in ("name", "phase", "reference_status", "dependencies"):
            if str(actual.get(field, "")).strip() != expected[field]:
                errors.append(
                    f"#{item_id} {field} drift: roadmap={expected[field]!r}, registry={actual.get(field)!r}"
                )

    counts: dict[str, int] = {}
    for entry in by_id.values():
        state = str(entry.get("verification", "INVALID"))
        counts[state] = counts.get(state, 0) + 1
    return errors, counts


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--roadmap", type=Path, default=None)
    parser.add_argument("--registry", type=Path, default=None)
    args = parser.parse_args()
    root = args.root.resolve()
    roadmap = (args.roadmap or root / "docs/ROADMAP.md").resolve()
    registry = (args.registry or root / "docs/roadmap_baseline.json").resolve()
    try:
        errors, counts = validate(root, roadmap, registry)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"ROADMAP BASELINE: FAIL: {error}")
        return 1
    print("ROADMAP BASELINE: PASS" if not errors else "ROADMAP BASELINE: FAIL")
    print(f"items=120 verification={json.dumps(counts, sort_keys=True)}")
    for error in errors:
        print(f"ERROR: {error}")
    return 0 if not errors else 1


if __name__ == "__main__":
    sys.exit(main())
