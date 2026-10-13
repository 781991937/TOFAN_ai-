import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/security/tofan_owner_command_authority.dart';

void main() {
  test('missing owner grant always denies privileged access', () {
    for (final permission in OwnerPermission.values) {
      expect(
        TofanOwnerCommandAuthority.authorize(
          grant: null,
          resource: 'academic_library/computer_science',
          permission: permission,
          now: DateTime.utc(2026, 10, 13),
        ),
        isFalse,
        reason: 'No client-side grant may be assumed for $permission',
      );
    }
  });
}
