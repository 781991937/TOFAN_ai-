import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/domain/execution/execution_models.dart';
import 'package:tofan_ai/domain/security/owner_authority.dart';

void main() {
  const authority = OwnerAuthority();

  test('configured owner has every tool permission', () {
    for (final permission in ToolPermission.values) {
      expect(authority.hasPermission('raedtofan86@gmail.com', permission), isTrue);
    }
    expect(authority.hasAllPermissions('raedtofan86@gmail.com'), isTrue);
  });

  test('non-owner does not inherit owner authority', () {
    expect(authority.isOwner('student-1'), isFalse);
    expect(
      authority.hasPermission('student-1', ToolPermission.administer),
      isFalse,
    );
  });
}
