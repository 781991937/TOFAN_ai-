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
  const _SettingsScreenState();

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

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
              'Local هو الوضع الافتراضي. مفاتيح مزودي الذكاء الاصطناعي لا تُدخل داخل تطبيق الطالب؛ الاتصال الخارجي يمر عبر البوابة الآمنة.',
              style: Theme.of(context).textTheme.bodySmall,
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
