import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/domain/execution/execution_models.dart';
import 'package:tofan_ai/domain/security/owner_authority.dart';

void main() {
  const authority = OwnerAuthority(ownerActorId: 'owner-1');

  test('configured owner has every tool permission', () {
    for (final permission in ToolPermission.values) {
      expect(authority.hasPermission('owner-1', permission), isTrue);
    }
    expect(authority.hasAllPermissions('owner-1'), isTrue);
  });

  test('email is never treated as owner identity', () {
    expect(authority.isOwner('raedtofan86@gmail.com'), isFalse);
  });

  test('unconfigured authority grants nothing', () {
    const unconfigured = OwnerAuthority();
    expect(unconfigured.isOwner('owner-1'), isFalse);
    expect(
      unconfigured.hasPermission('owner-1', ToolPermission.administer),
      isFalse,
    );
  });

  test('non-owner does not inherit owner authority', () {
    expect(authority.isOwner('student-1'), isFalse);
    expect(
      authority.hasPermission('student-1', ToolPermission.administer),
      isFalse,
    );
  });
}
