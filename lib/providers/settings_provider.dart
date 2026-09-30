import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/secure_storage_service.dart';
import '../ai/ai_core.dart';
import '../utils/constants.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

/// Controls the TOFAN AI Core execution mode.
/// Local is deliberately the default and requires no external API key.
class AiExecutionModeNotifier extends StateNotifier<AiExecutionMode> {
  AiExecutionModeNotifier() : super(AiExecutionMode.local) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('tofan_ai_execution_mode');
    if (stored == AiExecutionMode.openAi.name) state = AiExecutionMode.openAi;
    if (stored == AiExecutionMode.gemini.name) state = AiExecutionMode.gemini;
    if (stored == AiExecutionMode.local.name) state = AiExecutionMode.local;
  }

  Future<void> setMode(AiExecutionMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tofan_ai_execution_mode', mode.name);
  }
}

final aiExecutionModeProvider =
    StateNotifierProvider<AiExecutionModeNotifier, AiExecutionMode>((ref) {
  return AiExecutionModeNotifier();
});


/// Controls the current app-wide [ThemeMode], persisted to SharedPreferences.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(AppConstants.themeModeKey);
    switch (stored) {
      case 'light':
        state = ThemeMode.light;
      case 'dark':
        state = ThemeMode.dark;
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeModeKey, mode.name);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Controls which AI provider (OpenAI or Gemini) is currently active.
class AiProviderNotifier extends StateNotifier<AiProvider> {
  AiProviderNotifier() : super(AiProvider.openAi) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(AppConstants.selectedAiProviderKey);
    state = AiProviderX.fromStorageValue(stored);
  }

  Future<void> setProvider(AiProvider provider) async {
    state = provider;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        AppConstants.selectedAiProviderKey, provider.storageValue);
  }
}

final aiProviderNotifierProvider =
    StateNotifierProvider<AiProviderNotifier, AiProvider>((ref) {
  return AiProviderNotifier();
});

/// Exposes whether the OpenAI API key has been configured.
final openAiKeyConfiguredProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);
  final key = await storage.getOpenAiApiKey();
  return key != null && key.isNotEmpty;
});

/// Exposes whether the Gemini API key has been configured.
final geminiKeyConfiguredProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);
  final key = await storage.getGeminiApiKey();
  return key != null && key.isNotEmpty;
});
