import '../data/academic/academic_library_security.dart';
import '../data/academic/academic_library_security_catalog.dart';
import 'tofan_owner_command_authority.dart';

class LibraryAuthorizationGateway {
  LibraryAuthorizationGateway({LibrarySecurityPolicy? policy})
      : policy = policy ?? AcademicLibrarySecurityCatalog.policy;

  final LibrarySecurityPolicy policy;

  bool authorize({
    required LibrarySecurityRole role,
    required String domainId,
    required LibraryAccessOperation operation,
    OwnerCommandGrant? ownerGrant,
    DateTime? now,
  }) {
    if (policy.canAccess(role, domainId, operation)) return true;
    if (ownerGrant == null) return false;
    final permission = _permissionFor(operation);
    if (permission == null) return false;
    return TofanOwnerCommandAuthority.authorize(
      grant: ownerGrant,
      resource: 'academic_library/$domainId',
      permission: permission,
      now: now ?? DateTime.now().toUtc(),
    );
  }

  OwnerPermission? _permissionFor(LibraryAccessOperation operation) {
    switch (operation) {
      case LibraryAccessOperation.read:
        return OwnerPermission.read;
      case LibraryAccessOperation.search:
        return OwnerPermission.search;
      case LibraryAccessOperation.write:
        return OwnerPermission.write;
      case LibraryAccessOperation.export:
        return OwnerPermission.export;
      case LibraryAccessOperation.administer:
        return OwnerPermission.administer;
    }
  }
}
