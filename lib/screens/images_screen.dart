import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';

class ImagesScreen extends ConsumerStatefulWidget {
  const ImagesScreen({super.key});

  @override
  ConsumerState<ImagesScreen> createState() => _ImagesScreenState();
}

class _ImagesScreenState extends ConsumerState<ImagesScreen> {
  final _promptController = TextEditingController();
  bool _generating = false;
  String? _imageUrl;
  String? _error;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty || _generating) return;

    setState(() {
      _generating = true;
      _error = null;
      _imageUrl = null;
    });

    try {
      final storage = ref.read(secureStorageServiceProvider);
      final apiKey = await storage.getOpenAiApiKey();
      final service = ref.read(openAiServiceProvider);
      final url = await service.generateImage(apiKey: apiKey ?? '', prompt: prompt);
      setState(() => _imageUrl = url);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Images')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _promptController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe the image you want to create...',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generating ? null : _generate,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(_generating ? 'Generating...' : 'Generate image'),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: _buildPreview(theme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(ThemeData theme) {
    if (_generating) {
      return const CircularProgressIndicator();
    }
    if (_error != null) {
      return Text(
        _error!,
        style: TextStyle(color: theme.colorScheme.error),
        textAlign: TextAlign.center,
      );
    }
    if (_imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(_imageUrl!, fit: BoxFit.cover),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined, size: 64, color: theme.colorScheme.outline),
        const SizedBox(height: 12),
        const Text('Generated images will appear here'),
      ],
    );
  }
}
