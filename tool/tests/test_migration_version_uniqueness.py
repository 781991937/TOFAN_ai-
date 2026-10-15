from pathlib import Path
import unittest

from tool.check_migration_version_uniqueness import migration_name_issues


class MigrationVersionUniquenessTests(unittest.TestCase):
    def test_unique_versions_allow_gaps_and_timestamp_versions(self) -> None:
        paths = [
            Path("0001_baseline.sql"),
            Path("0003_backend_api_resources.sql"),
            Path("20261015172950_remove_unsafe_table_level_privileges.sql"),
        ]
        self.assertEqual(migration_name_issues(paths), [])

    def test_duplicate_numeric_versions_are_rejected_even_with_different_padding(self) -> None:
        paths = [
            Path("0003_backend_api_resources.sql"),
            Path("3_identity_verification_requests.sql"),
        ]
        issues = migration_name_issues(paths)
        self.assertEqual(len(issues), 1)
        self.assertIn("duplicate migration version 3", issues[0])

    def test_malformed_migration_filename_is_rejected(self) -> None:
        issues = migration_name_issues([Path("migration_without_version.sql")])
        self.assertEqual(len(issues), 1)
        self.assertIn("expected '<numeric-version>_<descriptive_name>.sql'", issues[0])


if __name__ == "__main__":
    unittest.main()
