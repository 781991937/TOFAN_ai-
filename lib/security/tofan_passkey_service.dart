import 'package:passkeys/passkeys.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Flutter client for the server-verified TOFAN passkey ceremony.
///
/// This is step-up authentication for an existing Supabase session, not a
/// passwordless Supabase login. The server remains responsible for WebAuthn
/// verification and owner authorization.
class TofanPasskeyService {
  TofanPasskeyService({
    SupabaseClient? client,
    PasskeyAuthenticator? authenticator,
  })  : _client = client ?? Supabase.instance.client,
        _authenticator = authenticator ?? PasskeyAuthenticator();

  final SupabaseClient _client;
  final PasskeyAuthenticator _authenticator;

  Future<void> registerPasskey() async {
    final optionsResponse = await _invoke('registration-options');
    final options = _map(optionsResponse['options'], 'options');
    final challengeId = _string(optionsResponse['challenge_id'], 'challenge_id');

    final request = RegisterRequestType.fromJson({
      'challenge': options['challenge'],
      'relyingParty': options['rp'],
      'user': options['user'],
      'excludeCredentials': options['excludeCredentials'] ?? <dynamic>[],
      'authSelectionType': options['authenticatorSelection'],
      'pubKeyCredParams': options['pubKeyCredParams'],
      'timeout': options['timeout'],
      'attestation': options['attestation'],
    });

    final credential = await _authenticator.register(request);
    await _invoke('registration-verify', {
      'challenge_id': challengeId,
      'response': credential.toJson(),
    });
  }

  /// Verifies the currently signed-in account's passkey with user verification.
  ///
  /// Returns a short-lived, single-use receipt issued only if the server confirms
  /// the account is the canonical TOFAN owner. Callers must keep it in memory
  /// and pass it only to a server operation that consumes it. Never persist or
  /// log this value. Current app actions are not yet wired to consume receipts.
  Future<String> verifyOwnerStepUp() async {
    final optionsResponse = await _invoke('authentication-options');
    final options = _map(optionsResponse['options'], 'options');
    final challengeId = _string(optionsResponse['challenge_id'], 'challenge_id');

    final request = AuthenticateRequestType.fromJson({
      'relyingPartyId': options['rpId'],
      'challenge': options['challenge'],
      'timeout': options['timeout'],
      'userVerification': options['userVerification'],
      'allowCredentials': options['allowCredentials'] ?? <dynamic>[],
    }, preferImmediatelyAvailableCredentials: false);

    final assertion = await _authenticator.authenticate(request);
    final verified = await _invoke('authentication-verify', {
      'challenge_id': challengeId,
      'response': assertion.toJson(),
    });
    return _string(verified['step_up_token'], 'step_up_token');
  }

  Future<Map<String, dynamic>> _invoke(
    String action, [
    Map<String, dynamic> extra = const {},
  ]) async {
    final session = _client.auth.currentSession;
    if (session == null) {
      throw const TofanPasskeyException(
        'سجّل الدخول إلى حسابك أولاً قبل إعداد مفتاح المرور.',
      );
    }

    try {
      final response = await _client.functions.invoke(
        'tofan-passkey-step-up',
        body: {'action': action, ...extra},
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );
      final data = _map(response.data, 'server_response');
      if (response.status < 200 || response.status >= 300) {
        throw const TofanPasskeyException('تعذّر إكمال التحقق من مفتاح المرور.');
      }
      return data;
    } on FunctionException {
      throw const TofanPasskeyException(
        'رفض الخادم الطلب أو تعذّر الاتصال بالخدمة. تأكد من تسجيل الدخول وإعداد الخدمة، ثم أعد المحاولة.',
      );
    }
  }

  Map<String, dynamic> _map(Object? value, String field) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    throw TofanPasskeyException('استجابة غير صالحة من خدمة مفتاح المرور: $field');
  }

  String _string(Object? value, String field) {
    if (value is String && value.isNotEmpty) return value;
    throw TofanPasskeyException('استجابة غير صالحة من خدمة مفتاح المرور: $field');
  }
}

class TofanPasskeyException implements Exception {
  const TofanPasskeyException(this.message);
  final String message;

  @override
  String toString() => message;
}
