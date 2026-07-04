import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/constants.dart';

/// Provides secure, encrypted persistence for sensitive values such as
/// API keys, backed by the platform keystore/keychain.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> saveOpenAiApiKey(String apiKey) =>
      _storage.write(key: AppConstants.openAiApiKeyStorageKey, value: apiKey);

  Future<String?> getOpenAiApiKey() =>
      _storage.read(key: AppConstants.openAiApiKeyStorageKey);

  Future<void> saveGeminiApiKey(String apiKey) =>
      _storage.write(key: AppConstants.geminiApiKeyStorageKey, value: apiKey);

  Future<String?> getGeminiApiKey() =>
      _storage.read(key: AppConstants.geminiApiKeyStorageKey);

  Future<void> deleteOpenAiApiKey() =>
      _storage.delete(key: AppConstants.openAiApiKeyStorageKey);

  Future<void> deleteGeminiApiKey() =>
      _storage.delete(key: AppConstants.geminiApiKeyStorageKey);

  Future<void> clearAll() => _storage.deleteAll();
}
