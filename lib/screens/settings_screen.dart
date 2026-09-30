import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import '../ai/ai_core.dart';
import '../utils/constants.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _openAiController = TextEditingController();
  final _geminiController = TextEditingController();

  @override
  void dispose() {
    _openAiController.dispose();
    _geminiController.dispose();
    super.dispose();
  }

  Future<void> _saveOpenAiKey() async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.saveOpenAiApiKey(_openAiController.text.trim());
    ref.invalidate(openAiKeyConfiguredProvider);
    _openAiController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('OpenAI API key saved')));
    }
  }

  Future<void> _saveGeminiKey() async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.saveGeminiApiKey(_geminiController.text.trim());
    ref.invalidate(geminiKeyConfiguredProvider);
    _geminiController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Gemini API key saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final aiProvider = ref.watch(aiProviderNotifierProvider);
    final openAiConfigured = ref.watch(openAiKeyConfiguredProvider);
    final geminiConfigured = ref.watch(geminiKeyConfiguredProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) =>
                  ref.read(themeModeProvider.notifier).setThemeMode(selection.first),
            ),
            const SizedBox(height: 24),
            Text(
              'TOFAN AI execution mode',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<AiExecutionMode>(
              segments: const [
                ButtonSegment(
                  value: AiExecutionMode.local,
                  label: Text('Local'),
                  icon: Icon(Icons.memory_outlined),
                ),
                ButtonSegment(
                  value: AiExecutionMode.openAi,
                  label: Text('OpenAI'),
                ),
                ButtonSegment(
                  value: AiExecutionMode.gemini,
                  label: Text('Gemini'),
                ),
              ],
              selected: {ref.watch(aiExecutionModeProvider)},
              onSelectionChanged: (selection) => ref
                  .read(aiExecutionModeProvider.notifier)
                  .setMode(selection.first),
            ),
            const SizedBox(height: 6),
            Text(
              'Local هو الوضع الافتراضي ولا يحتاج إلى مفتاح API.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Text('Default AI provider', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<AiProvider>(
              segments: const [
                ButtonSegment(value: AiProvider.openAi, label: Text('OpenAI')),
                ButtonSegment(value: AiProvider.gemini, label: Text('Gemini')),
              ],
              selected: {aiProvider},
              onSelectionChanged: (selection) =>
                  ref.read(aiProviderNotifierProvider.notifier).setProvider(selection.first),
            ),
            const SizedBox(height: 24),
            Text('API keys', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            openAiConfigured.when(
              data: (configured) => _ApiKeyTile(
                label: 'OpenAI API key',
                configured: configured,
                controller: _openAiController,
                onSave: _saveOpenAiKey,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            geminiConfigured.when(
              data: (configured) => _ApiKeyTile(
                label: 'Google Gemini API key',
                configured: configured,
                controller: _geminiController,
                onSave: _saveGeminiKey,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiKeyTile extends StatelessWidget {
  const _ApiKeyTile({
    required this.label,
    required this.configured,
    required this.controller,
    required this.onSave,
  });

  final String label;
  final bool configured;
  final TextEditingController controller;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label, style: Theme.of(context).textTheme.titleSmall),
                ),
                Icon(
                  configured ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 18,
                  color: configured
                      ? Colors.green
                      : Theme.of(context).colorScheme.outline,
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: configured ? 'Replace saved key' : 'Enter API key',
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onSave, child: const Text('Save')),
            ),
          ],
        ),
      ),
    );
  }
}
