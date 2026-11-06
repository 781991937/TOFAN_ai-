import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/backend/api/api_models.dart';
import 'package:tofan_ai/backend/api/owner_authorization.dart';

const _ownerId = '00000000-0000-4000-8000-000000000001';
const _otherId = '00000000-0000-4000-8000-000000000002';

void main() {
  group('OwnerAuthorizationPolicy', () {
    test('allows only the configured UUID with trusted owner role', () {
      final policy = OwnerAuthorizationPolicy(ownerUserId: _ownerId);
      expect(
        policy.allows(const ApiPrincipal(userId: _ownerId, role: 'owner')),
        isTrue,
      );
      expect(
        policy.allows(const ApiPrincipal(userId: _ownerId, role: 'student')),
        isFalse,
      );
      expect(
        policy.allows(const ApiPrincipal(userId: _otherId, role: 'owner')),
        isFalse,
      );
    });

    test('normalizes UUID case and surrounding whitespace', () {
      final policy = OwnerAuthorizationPolicy(
        ownerUserId: '  ${_ownerId.toUpperCase()}  ',
      );
      expect(
        policy.allows(const ApiPrincipal(userId: _ownerId, role: 'owner')),
        isTrue,
      );
    });

    test('fails closed when owner identity is missing or malformed', () {
      for (final value in ['', 'not-a-uuid', '  ']) {
        final policy = OwnerAuthorizationPolicy(ownerUserId: value);
        expect(policy.isConfigured, isFalse);
        expect(
          () => policy.requireOwner(
            const ApiPrincipal(userId: _ownerId, role: 'owner'),
          ),
          throwsA(
            isA<ApiException>()
                .having((error) => error.statusCode, 'statusCode', 503)
                .having(
                  (error) => error.code,
                  'code',
                  'owner_authorization_not_configured',
                ),
          ),
        );
      }
    });

    test('rejects every non-owner principal with 403', () {
      final policy = OwnerAuthorizationPolicy(ownerUserId: _ownerId);
      expect(
        () => policy.requireOwner(
          const ApiPrincipal(userId: _otherId, role: 'owner'),
        ),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 403)
              .having((error) => error.code, 'code', 'owner_required'),
        ),
      );
      expect(
        () => policy.requireOwner(
          const ApiPrincipal(userId: _ownerId, role: 'student'),
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
